{ inputs, ... }:

{
  imports = [
    inputs.chena.nixosModules.default
    ./fcitx5-hyprland.nix
    ./fonts.nix
  ];

  chena = {
    enable = true;
    wallpaper = ../../../bg.png;
    airpods.appleDeviceId = true;
  };

  # NixOS ignores the [Install] section of the upstream unit, so upower only
  # starts on D-Bus activation. Without it running, the shell shows no battery
  # and the critical battery action never fires.
  systemd.services.upower.wantedBy = [ "graphical.target" ];
}
