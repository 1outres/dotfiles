{
  hostname,
  inputs,
  lib,
  pkgs,
  system,
  username,
  ...
}:

let
  # explorer.exe takes both URLs and Windows paths, and unlike `cmd.exe /c
  # start` it does not split a URL on `&`. It exits 1 even on success.
  winOpen = pkgs.writeShellScriptBin "win-open" ''
    target=$1
    if [ -e "$target" ]; then
      target=$(/bin/wslpath -w "$target")
    fi
    /mnt/c/Windows/explorer.exe "$target" || true
  '';
in
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    inputs.self.nixosModules.sshd
    inputs.self.nixosModules.mosh
    ./paseo.nix
  ];

  # Mirrored networking shares the port space with Windows, whose own OpenSSH
  # server already holds 22. Clients reach this sshd with `-p 2222`.
  services.openssh.ports = lib.mkForce [ 2222 ];

  wsl = {
    enable = true;
    # Creates the user (isNormalUser, uid 1000, wheel) and makes it the login
    # user in /etc/wsl.conf. Changing it on a running distro needs
    # `switch-to-configuration boot` and a `wsl --terminate`, not a live switch.
    defaultUser = username;

    # WSL regenerates /etc/hosts from the Windows hosts file by default, and
    # NixOS-WSL then drops environment.etc.hosts, which would silently discard
    # the networking.hosts entries from modules/os/nixos/core.nix.
    wslConf.network.generateHosts = false;
  };

  # Hand URLs and files to the Windows default handler, so login flows (gh,
  # claude, codex) land in the Windows browser. wslu's wslview used to do this
  # but nixpkgs dropped it once the project was archived.
  environment.systemPackages = [ winOpen ];
  environment.sessionVariables.BROWSER = "win-open";

  networking.hostName = hostname;

  nixpkgs.hostPlatform = system;

  time.timeZone = "Asia/Tokyo";

  security.sudo.wheelNeedsPassword = false;

  users.users.${username} = {
    # wheel/docker/netbird come from modules/os/nixos/core.nix.
    # isNormalUser defaults the shell to bash; pin zsh to resolve the
    # mkDefault tie with modules/os/nixos/core.nix (programs.zsh.enable).
    shell = pkgs.zsh;
  };

  # NixOS release this host was first installed with. Do not bump casually.
  system.stateVersion = "26.05";
}
