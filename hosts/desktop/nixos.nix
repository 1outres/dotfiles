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
      ../../modules/desktop/fonts.nix
      ../../modules/desktop/i18n.nix
      ../../modules/desktop/audio.nix

      ./hardware-configuration.nix
    ]
    ++ (with inputs.nixos-hardware.nixosModules; [
      common-cpu-amd
      common-gpu-nvidia-nonprime
      common-pc-ssd
    ]);

  hardware = {
    nvidia.open = true;
    bluetooth.enable = false;
    opengl = {
      enable = true;
    };
  };

  networking = {
    hostName = "loutres-desktop";
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  system.stateVersion = "24.05";
}
