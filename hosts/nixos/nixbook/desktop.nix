{ inputs, ... }:

{
  imports = [
    inputs.chena.nixosModules.default
    ../../../modules/os/nixos/fonts.nix
  ];

  chena = {
    enable = true;
    wallpaper = ../../../bg.png;
    airpods.appleDeviceId = true;
  };
}
