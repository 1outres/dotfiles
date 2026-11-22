{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.stay-awake-networks;

  connectionList = pkgs.writeText "stay-awake-connections" (
    lib.concatMapStrings (name: "${name}\n") cfg.connections
  );

  inhibit = pkgs.writeShellApplication {
    name = "stay-awake-networks-inhibit";
    runtimeInputs = [
      pkgs.coreutils
      config.systemd.package
    ];
    text = ''
      exec systemd-inhibit \
        --what=idle \
        --who=stay-awake-networks \
        --why="Connected to a network that keeps the machine awake" \
        --mode=block \
        sleep infinity
    '';
  };

  dispatcher = pkgs.writeShellApplication {
    name = "stay-awake-networks-dispatcher";
    runtimeInputs = [
      config.networking.networkmanager.package
      config.systemd.package
      pkgs.gnugrep
    ];
    text = ''
      case "$2" in
        up | down) ;;
        *) exit 0 ;;
      esac

      # Look at every active connection, not only the one in this event, so
      # that a "down" of another connection does not end the inhibitor.
      if nmcli --get-values NAME connection show --active | grep --quiet --fixed-strings --line-regexp --file=${connectionList}; then
        systemctl --no-block start stay-awake-networks.service
      else
        systemctl --no-block stop stay-awake-networks.service
      fi
    '';
  };
in
{
  options.services.stay-awake-networks = {
    enable = lib.mkEnableOption "keeping the machine awake while idle on some networks";

    connections = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      example = [ "Home Wi-Fi" ];
      description = ''
        NetworkManager connection names. While one of them is active, the idle
        daemon does not lock the session or turn the screen off. Closing the
        lid still suspends the machine.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.networking.networkmanager.enable;
        message = "services.stay-awake-networks needs NetworkManager.";
      }
    ];

    systemd.services.stay-awake-networks = {
      description = "Keep the machine awake while idle";
      serviceConfig.ExecStart = lib.getExe inhibit;
    };

    networking.networkmanager.dispatcherScripts = [
      {
        source = lib.getExe dispatcher;
        type = "basic";
      }
    ];
  };
}
