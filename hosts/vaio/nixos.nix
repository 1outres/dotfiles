{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports =
    [
      ../../modules/core/i18n.nix
      ../../modules/core/nix.nix
      ../../modules/core/user.nix
      ../../modules/programs/hyprland.nix
      ../../modules/programs/shell.nix
      ../../modules/programs/ssh.nix
      ../../modules/programs/tailscale.nix
      ../../modules/desktop/fonts.nix
      ../../modules/desktop/i18n.nix
      ../../modules/desktop/audio.nix

      ./hardware-configuration.nix
    ]
    ++ (with inputs.nixos-hardware.nixosModules; [
      common-cpu-intel
      common-gpu-intel
      common-pc-laptop
      common-pc-ssd
    ]);

  hardware = {
    bluetooth.enable = true;
    opengl = {
      enable = true;
    };
  };

  networking = {
    hostName = "loutres-desktop";
    networkmanager.enable = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  system.stateVersion = "24.05";
}
