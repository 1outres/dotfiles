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
    interfaces."enp6s0" = {
      useDHCP = false;
      ipv4 = {
        addresses = [{
          address = "10.225.128.250";
          prefixLength = 24;
        }];
        routes = [{
          address = "10.225.0.0";
          prefixLength = 16;
          via = "10.225.128.254";
        }
        {
          address = "192.168.51.0";
          prefixLength = 24;
          via = "10.225.128.254";
        }];
      };
    };
    interfaces."enp9s0" = {
      useDHCP = true;
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  system.stateVersion = "24.05";
}
