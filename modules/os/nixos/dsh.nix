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

  userHome = config.users.users.${cfg.user}.home;

  # dsh exits at once when it cannot bind, and an address from a VPN client
  # shows up some time after boot. Hold the start until the address exists.
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

    workingDirectory = lib.mkOption {
      type = lib.types.path;
      default = userHome;
      defaultText = lib.literalExpression "config.users.users.\${config.services.dsh.user}.home";
      description = "Directory dsh starts in. dsh uses it as its default filesystem location.";
    };
  };

  config = lib.mkIf cfg.enable {
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
        );
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
