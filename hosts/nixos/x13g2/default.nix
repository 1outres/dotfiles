{
  hostname,
  inputs,
  pkgs,
  username,
  ...
}:

{
  imports = [
    inputs.private.nixosModules.hardware-x13g2
    ./power.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x13-amd
    ../../../modules/os/nixos/sshd.nix
    ../../../modules/os/nixos/gnome.nix
    ../../../modules/os/nixos/keyd.nix
    ../../../modules/os/nixos/onepassword.nix
  ];

  # Tray app for the NetBird client. Only useful where there is a desktop, so
  # it stays off in modules/os/nixos/core.nix.
  services.netbird.clients.default.ui.enable = true;

  environment.systemPackages = [
    pkgs.pciutils
    # Secure Boot key management. It is always run through sudo, so the system
    # profile is where it has to be.
    pkgs.sbctl
  ];

  networking.hostName = hostname;

  # nixpkgs.hostPlatform is set by the hardware module.

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Asia/Tokyo";

  # "us" even though the built-in keyboard is JIS: keyd remaps that board to its
  # printed layout (modules/os/nixos/keyd.nix), and the external one is already
  # US. This also lands in localed, which GNOME reads on login and writes into
  # org.gnome.desktop.input-sources, so leaving it at "jp" would undo the
  # session layout on every login.
  services.xserver.xkb.layout = "us";

  # Keep the interface language English, but format dates, money and addresses
  # the Japanese way.
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  networking.networkmanager.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  security.sudo.wheelNeedsPassword = false;

  # Normal interactive user. home / shell / extraGroups (wheel, docker, netbird)
  # are provided by modules/os/nixos/core.nix.
  users.users.${username} = {
    isNormalUser = true;
    # wheel/docker/netbird come from modules/os/nixos/core.nix.
    extraGroups = [ "networkmanager" ];
    # isNormalUser defaults the shell to bash; pin zsh to resolve the
    # mkDefault tie with modules/os/nixos/core.nix (programs.zsh.enable).
    shell = pkgs.zsh;
    # SSH key login works out of the box via modules/os/nixos/sshd.nix.
    # For console/password login set a hashed password, e.g.:
    #   hashedPassword = "$6$...";   # generate with: mkpasswd -m sha-512
  };

  # NixOS release this host was first installed with. Do not bump casually.
  system.stateVersion = "26.11";
}
