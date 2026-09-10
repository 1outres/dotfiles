{ lib, pkgs, ... }:

# Adaptive Backlight Management. The panel draws more than anything else on
# this machine, and amdgpu can dim its backlight while it raises the pixel
# values to make up for it. Levels run from 0 (off) to 4, and 1 is the mildest
# one, so the shift in colour stays hard to spot.
#
# The driver leaves this off and TLP has no setting for it, so the AC and the
# battery case are wired up here by hand.

let
  panelPowerSavings = pkgs.writeShellApplication {
    name = "amdgpu-panel-power-savings";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      level=0
      systemd-ac-power || level=1

      for node in /sys/class/drm/card*-eDP-*/amdgpu/panel_power_savings; do
        [ -e "$node" ] || continue
        echo "$level" > "$node"
      done
    '';
  };
in
{
  # Two triggers, because the order in which the ACPI adapter and the panel
  # appear is not fixed: whichever comes second runs the same script again.
  # Reading the adapter inside the script, rather than matching on it, is what
  # lets both rules stay the same.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="${lib.getExe panelPowerSavings}"
    ACTION=="add", SUBSYSTEM=="drm", ENV{DEVTYPE}=="drm_connector", KERNEL=="*-eDP-*", RUN+="${lib.getExe panelPowerSavings}"
  '';
}
