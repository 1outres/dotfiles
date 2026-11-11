{
  config,
  inputs,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.dsh;
  proxy = cfg.loopbackProxy;

  userHome = config.users.users.${cfg.user}.home;
  upstream = "${cfg.host}:${toString cfg.port}";

  proxyListen = [
    {
      addr = proxy.listenAddress;
      inherit (proxy) port;
    }
  ];

  # dsh and nginx exit at once when they cannot bind, and an address from a VPN
  # client shows up some time after boot. Hold the start until the address exists.
  waitForAddress = pkgs.writeShellApplication {
    name = "dsh-wait-for-address";
    runtimeInputs = [ pkgs.iproute2 ];
    text = ''
      until [[ -n "$(ip -o address show to "$1")" ]]; do
        sleep 1
      done
    '';
  };
in
{
  options.services.dsh = {
    enable = lib.mkEnableOption "the DeepSeek Harness (dsh) Web UI";

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.dsh;
      defaultText = lib.literalExpression "inputs.llm-agents.packages.\${system}.dsh";
      description = "The dsh package to run.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      description = "User that runs dsh. The agent runs its commands as this user.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "users";
      description = "Group that runs dsh.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = ''
        IP address to listen on. dsh takes one concrete IPv4 or IPv6 address
        of a local interface and rejects wildcard addresses.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3080;
      description = "TCP port to listen on.";
    };

    trustedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "dsh.example.com" ];
      description = ''
        Extra Host authorities (host or host:port) that dsh accepts. Loopback
        and the listen address are always accepted.
      '';
    };

    publicUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "https://dsh.example.com/";
      description = ''
        URL that browsers use, when a reverse proxy is in front of dsh. dsh
        prints it with the launch token and shows it to the agent. It grants
        no trust; also list its host in trustedHosts.
      '';
    };

    workingDirectory = lib.mkOption {
      type = lib.types.path;
      default = userHome;
      defaultText = lib.literalExpression "config.users.users.\${config.services.dsh.user}.home";
      description = "Directory dsh starts in. dsh uses it as its default filesystem location.";
    };

    loopbackProxy = {
      enable = lib.mkEnableOption ''
        an nginx proxy that makes remote browsers look like loopback to dsh.
        Plugins such as dsh-web-all refuse every non-loopback caller, so they
        do not work behind a plain reverse proxy
      '';

      listenAddress = lib.mkOption {
        type = lib.types.str;
        description = "IP address the proxy listens on.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 3090;
        description = "TCP port the proxy listens on.";
      };

      publicHost = lib.mkOption {
        type = lib.types.str;
        example = "dsh.example.com";
        description = ''
          Host name that browsers use. Something in front of this proxy must
          serve it over HTTPS and pass the browser's Host header unchanged.
        '';
      };

      selfAuthenticatedPaths = lib.mkOption {
        type = lib.types.listOf (lib.types.strMatching "/.+");
        default = [ ];
        example = [ "/remote-serial/agent" ];
        description = ''
          Exact paths that the proxy passes to dsh without the session cookie
          check. List only routes that authenticate every caller themselves,
          such as the serial agent gateway of the remote plugin, which accepts
          only agents that sign with a key listed in its settings.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        # `dsh plugin` and the Web UI's plugin manager both run pnpm from PATH. The
        # service PATH below includes the system profile, so this covers both.
        environment.systemPackages = [
          cfg.package
          pkgs.pnpm
        ];

        systemd.services.dsh = {
          description = "DeepSeek Harness Web UI";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          # The agent runs shell commands, so it gets the tools of the user's
          # login shell. dsh's Linux sandbox looks up bwrap on PATH. mkForce
          # replaces the minimal PATH that the NixOS systemd module sets.
          environment.PATH = lib.mkForce (
            lib.concatStringsSep ":" [
              (lib.makeBinPath [ pkgs.bubblewrap ])
              "${userHome}/.nix-profile/bin"
              "${userHome}/.local/state/nix/profile/bin"
              "/etc/profiles/per-user/${cfg.user}/bin"
              "/run/current-system/sw/bin"
              "/run/wrappers/bin"
              "/nix/var/nix/profiles/default/bin"
            ]
          );

          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            Group = cfg.group;
            WorkingDirectory = cfg.workingDirectory;
            ExecStartPre = utils.escapeSystemdExecArgs [
              (lib.getExe waitForAddress)
              cfg.host
            ];
            ExecStart = utils.escapeSystemdExecArgs (
              [
                (lib.getExe cfg.package)
                "web"
                "--no-open"
                "--host"
                cfg.host
                "--port"
                (toString cfg.port)
              ]
              ++ lib.concatMap (host: [
                "--trusted-host"
                host
              ]) cfg.trustedHosts
              ++ lib.optionals (cfg.publicUrl != null) [
                "--public-url"
                cfg.publicUrl
              ]
            );
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
      }

      (lib.mkIf proxy.enable {
        assertions = [
          {
            assertion = cfg.host == "127.0.0.1";
            message = "services.dsh.loopbackProxy needs services.dsh.host = \"127.0.0.1\": plugins check that the socket peer is loopback.";
          }
        ];

        services.dsh.publicUrl = lib.mkDefault "https://${proxy.publicHost}/";

        # The unit's sandbox blocks the netlink socket that `ip` uses, so this
        # step runs outside it ("+").
        systemd.services.nginx.serviceConfig.ExecStartPre = lib.mkBefore [
          "+${lib.getExe waitForAddress} ${proxy.listenAddress}"
        ];

        services.nginx = {
          enable = true;

          # A request from any other site keeps its own Origin, so dsh and the
          # plugins still refuse it.
          appendHttpConfig = ''
            map $http_origin $dsh_upstream_origin {
              default $http_origin;
              "https://${proxy.publicHost}" "http://${upstream}";
            }
          '';

          virtualHosts = {
            "dsh-unknown-host" = {
              serverName = "_";
              default = true;
              listen = proxyListen;
              extraConfig = "return 444;";
            };

            ${proxy.publicHost} = {
              listen = proxyListen;

              # access_log is off because the login URL carries the launch token.
              extraConfig = ''
                access_log off;
                client_max_body_size 0;

                proxy_http_version 1.1;
                proxy_buffering off;
                proxy_request_buffering off;
                proxy_read_timeout 1d;
                proxy_send_timeout 1d;

                proxy_set_header Host ${upstream};
                proxy_set_header Origin $dsh_upstream_origin;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection $connection_upgrade;
                proxy_set_header Forwarded "";
                proxy_set_header X-Forwarded-For "";
                proxy_set_header X-Forwarded-Host "";
                proxy_set_header X-Forwarded-Proto "";
                proxy_set_header X-Real-IP "";
                proxy_set_header CF-Connecting-IP "";

                proxy_cookie_flags ~ secure;
              '';

              locations = {
                # dsh answers GET / with 200 only for a valid session cookie.
                "= /_dsh_auth" = {
                  extraConfig = ''
                    internal;
                    proxy_pass http://${upstream}/;
                    proxy_method GET;
                    proxy_pass_request_body off;
                    proxy_set_header Content-Length "";
                    proxy_set_header Host ${upstream};
                    proxy_set_header Origin "";
                    proxy_set_header Upgrade "";
                    proxy_set_header Connection "";
                  '';
                };

                # The login. dsh turns the launch token into a session cookie here.
                "= /".proxyPass = "http://${upstream}";

                # Plugin routes have no login of their own: they trust any
                # loopback caller. Everything that reaches dsh through this
                # proxy looks like loopback, so the proxy must check the session
                # cookie first, or the plugins would be open to anyone who can
                # reach the public host name.
                "/" = {
                  proxyPass = "http://${upstream}";
                  extraConfig = "auth_request /_dsh_auth;";
                };
              }
              // lib.genAttrs (map (path: "= ${path}") proxy.selfAuthenticatedPaths) (_: {
                proxyPass = "http://${upstream}";
              });
            };
          };
        };
      })
    ]
  );
}
