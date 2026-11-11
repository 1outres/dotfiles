{
  hostname,
  lib,
  pkgs,
  username,
  ...
}:

{
  imports = [
    ./aurora.nix
    ./desktop.nix
    ../../../modules/os/nixos/locale.nix
    ../../../modules/os/nixos/tmcit-ca.nix
  ];

  networking.hostName = hostname;

  # nixpkgs.hostPlatform is set by the Aurora module.

  aurora.desktop = "minimal";

  # Filesystem identities of this machine's disk, from the /etc/nixos that the
  # Aurora installer wrote.
  aurora.imageLayout = lib.mkForce {
    rootUUID = "3e38403c-c023-5cd8-ad8a-2b5201ea9a1e";
    bootUUID = "8fa8c04c-7c24-55db-bbf5-5b077e43a6a5";
    efiUUID = "1F0F-7CA6";
  };

  # Aurora's first boot set this to false after it rekeyed the disk. Leaving it
  # true would bring back its first-password PAM hooks.
  aurora.firstboot.passwordHooks = false;

  security.sudo.wheelNeedsPassword = false;

  users.users.${username} = {
    isNormalUser = true;
    # Written by Aurora's first boot, so the hash stays out of the Nix store.
    hashedPasswordFile = "/var/lib/aurora/owner-password.hash";
    # isNormalUser defaults the shell to bash; pin zsh to resolve the
    # mkDefault tie with modules/os/nixos/core.nix (programs.zsh.enable).
    shell = pkgs.zsh;
  };

  # Aurora sets its own release here and may raise it later. Keep the release
  # this host was first installed with.
  system.stateVersion = lib.mkForce "26.05";
}
