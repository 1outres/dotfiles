{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.bluetooth-public-address;

  index = lib.removePrefix "hci" cfg.adapter;
  deviceUnit = "sys-subsystem-bluetooth-devices-${cfg.adapter}.device";

  setPublicAddress = pkgs.writeShellApplication {
    name = "bluetooth-set-public-address";
    runtimeInputs = [
      config.hardware.bluetooth.package
      pkgs.gawk
    ];
    text = ''
      index=$1
      address=$2

      current_address() {
        btmgmt --index "$index" info | awk '$1 == "addr" { print $2; exit }'
      }

      # btmgmt exits with 0 even when a command fails, so check its output.
      run() {
        local expected=$1
        shift
        local output
        output=$(btmgmt --index "$index" "$@")
        if [[ $output != *"$expected"* ]]; then
          echo "$output" >&2
          exit 1
        fi
      }

      # The adapter joins the management interface only after the kernel has
      # set it up.
      until [[ -n "$(current_address)" ]]; do
        sleep 1
      done

      if [[ "$(current_address)" == "$address" ]]; then
        exit 0
      fi

      run "Set Powered complete" power off
      run "Set Public Address complete" public-addr "$address"

      # The kernel sets up the adapter again with the new address in the
      # background.
      until [[ "$(current_address)" == "$address" ]]; do
        sleep 1
      done
    '';
  };
in
{
  options.services.bluetooth-public-address = {
    enable = lib.mkEnableOption "a custom public address for a Bluetooth adapter";

    adapter = lib.mkOption {
      type = lib.types.strMatching "hci[0-9]+";
      default = "hci0";
      description = "Bluetooth adapter to give the address to.";
    };

    address = lib.mkOption {
      type = lib.types.strMatching "([0-9A-F]{2}:){5}[0-9A-F]{2}";
      example = "6E:7E:67:D9:66:FF";
      description = ''
        Public address to give the adapter, in upper case. The kernel forgets
        it when the adapter goes away, so it is set again each time bluetoothd
        starts. The adapter driver has to support changing the address.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.bluetooth-public-address = {
      description = "Set the public address of Bluetooth adapter ${cfg.adapter}";
      bindsTo = [ deviceUnit ];
      after = [ deviceUnit ];
      before = [ "bluetooth.service" ];
      # bluetoothd must not run with the original address, or a new pairing
      # would replace the one made with that address.
      requiredBy = [ "bluetooth.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = 30;
        ExecStart = "${lib.getExe setPublicAddress} ${index} ${cfg.address}";
      };
    };
  };
}
