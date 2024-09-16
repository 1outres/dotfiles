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
      ../../modules/core/wg-client.nix
      ../../modules/core/yubikey.nix
      ../../modules/programs/hyprland.nix
      ../../modules/programs/shell.nix
      ../../modules/programs/ssh.nix
      ../../modules/programs/tailscale.nix
      ../../modules/desktop/fonts.nix
      ../../modules/desktop/i18n.nix
      ../../modules/desktop/audio.nix

      ./hardware-configuration.nix
      ./apple-silicon-support
    ];

  hardware = {
    asahi = {
      peripheralFirmwareDirectory = /etc/nixos/firmware;
      #extractPeripheralFirmware = false;
      useExperimentalGPUDriver = true;
      experimentalGPUInstallMode = "overlay";
      withRust = true;
    };
    bluetooth.enable = true;
    opengl = {
      enable = true;
    };
  };

  networking = {
    hostName = "loutres-mbp";
    networkmanager.enable = true;

    wireguard.interfaces.wg0 = {
      ips = [ "10.225.11.131/32" ];
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
    };
  };

  system.stateVersion = "24.11";
}
