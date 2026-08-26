{
  config,
  inputs,
  lib,
  pkgs,
  system,
  ...
}:

# sitka is the local gateway Claude Code talks to. modules/home/claude/settings.json
# sets ANTHROPIC_BASE_URL for every host, so Claude Code stops working on a host
# where the gateway is not running. That is why this module is imported from the
# shared users/loutres/home.nix rather than per host.

let
  # Branch on the system string rather than on pkgs: reading pkgs to decide
  # which attributes this module defines makes the module system recurse.
  isDarwin = lib.hasSuffix "-darwin" system;

  sitka = inputs.sitka.packages.${system}.default;

  configPath = "${config.home.homeDirectory}/.config/sitka/config.yaml";

  # Provider API keys live in this file, so it stays out of the store and out of
  # this repository. A fresh host gets a passthrough-only config, which serves
  # Claude models and leaves external providers to be added by hand.
  seedConfig = pkgs.writeText "sitka-config.yaml" ''
    listen: 127.0.0.1:8787

    anthropic:
      base_url: https://api.anthropic.com
  '';

  common = {
    home.packages = [ sitka ];

    home.activation.sitkaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e "${configPath}" ]; then
        run mkdir -p "$(dirname "${configPath}")"
        run cp ${seedConfig} "${configPath}"
        run chmod 600 "${configPath}"
      fi
    '';
  };

  linux = {
    systemd.user.services.sitka = {
      Unit = {
        Description = "sitka gateway for Claude Code";
        After = [ "network.target" ];
      };

      Service = {
        ExecStart = "${lib.getExe sitka} serve";
        # Claude Code has no way back once ANTHROPIC_BASE_URL points here, so a
        # crash must not leave the gateway down.
        Restart = "always";
        RestartSec = 5;
      };

      Install.WantedBy = [ "default.target" ];
    };
  };

  darwin = {
    launchd.agents.sitka = {
      enable = true;
      config = {
        ProgramArguments = [
          (lib.getExe sitka)
          "serve"
        ];
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
  };
in
lib.mkMerge [
  common
  (lib.optionalAttrs (!isDarwin) linux)
  (lib.optionalAttrs isDarwin darwin)
]
