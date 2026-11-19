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
}
