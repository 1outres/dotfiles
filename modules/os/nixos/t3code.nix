{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.t3code;
  userHome = "/home/${cfg.user}";
in
{
  options.services.t3code = {
    enable = lib.mkEnableOption "T3 Code, a self-hosted web GUI for coding agents";

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.t3code;
      defaultText = lib.literalExpression "inputs.llm-agents.packages.\${pkgs.stdenv.hostPlatform.system}.t3code";
      description = "The t3code package providing the `t3` server CLI.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      example = "alice";
      description = ''
        User account the server runs as. Everything the agents do happens as
        this user, so it has to be a real login account that already holds the
        agent CLIs and their credentials.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "users";
      description = "Group the server runs as.";
    };

    baseDir = lib.mkOption {
      type = lib.types.str;
      default = "${userHome}/.t3";
      defaultText = lib.literalExpression ''"/home/''${cfg.user}/.t3"'';
      description = ''
        Directory for server state (T3CODE_HOME): the SQLite database, the git
        worktrees it creates for sessions, and the logs.
      '';
    };

    workingDirectory = lib.mkOption {
      type = lib.types.str;
      default = userHome;
      defaultText = lib.literalExpression ''"/home/''${cfg.user}"'';
      description = "Directory new provider sessions start in.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
      description = "Address the HTTP/WebSocket server binds to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3773;
      description = "Port the HTTP/WebSocket server listens on.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for the server port.";
    };

    telemetry = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to let the server send usage events to the PostHog instance
        upstream builds into the client. Upstream defaults this to on.
      '';
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = lib.literalExpression ''{ T3CODE_LOG_LEVEL = "debug"; }'';
      description = "Extra environment variables for the server.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.baseDir} 0700 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.t3code = {
      description = "T3 Code - self-hosted web GUI for coding agents";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        NODE_ENV = "production";
        T3CODE_TELEMETRY_ENABLED = lib.boolToString cfg.telemetry;

        # mkForce replaces the store-only PATH NixOS gives every unit. The
        # agents this server starts need the same tools the user has in a login
        # shell, and on this setup those live in the home-manager profile.
        PATH = lib.mkForce (
          lib.concatStringsSep ":" [
            "${userHome}/.nix-profile/bin"
            "${userHome}/.local/state/nix/profile/bin"
            "/etc/profiles/per-user/${cfg.user}/bin"
            "/run/current-system/sw/bin"
            "/run/wrappers/bin"
            "/nix/var/nix/profiles/default/bin"
          ]
        );
      }
      // cfg.environment;

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.workingDirectory;

        # `serve` rather than `start`: it skips opening a browser and prints a
        # pairing token, which is the only way a remote client can log in.
        ExecStart = lib.concatStringsSep " " [
          (lib.getExe' cfg.package "t3")
          "serve"
          "--host ${cfg.host}"
          "--port ${toString cfg.port}"
          "--base-dir ${cfg.baseDir}"
        ];

        Restart = "on-failure";
        RestartSec = 5;

        KillSignal = "SIGTERM";
        TimeoutStopSec = 15;
      };
    };

    environment.systemPackages = [ cfg.package ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
