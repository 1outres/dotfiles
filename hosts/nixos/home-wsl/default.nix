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
    ./dsh.nix
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

  # NixOS-WSL turns off boot.modprobeConfig, so boot.kernelModules is never
  # loaded here. The kernel still loads most modules on demand, but it does so
  # in the WSL VM root, so kernel.modprobe must stay /sbin/modprobe: a Nix store
  # path does not exist there. The vhost modules are never loaded on demand,
  # because their device nodes only appear after the modules load.
  # Kata Containers and KubeVirt in the mNi e2e kind cluster need them, and a
  # privileged kind node only sees the host devices that exist when Docker
  # starts it.
  systemd.services.kvm-guest-modules = {
    description = "Load kernel modules for KVM guests";
    wantedBy = [ "multi-user.target" ];
    before = [ "docker.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.kmod}/bin/modprobe -a kvm_amd tun vhost_net vhost_vsock";
    };
  };

  # Mirrored networking sends local TCP to 127.0.0.1 out through loopback0 and
  # back in. Docker drops packets for ports published on 127.0.0.1 unless they
  # come in on lo, so every such port (kind API server, local registry) times
  # out. This turns off those raw table rules. Packets from the LAN to
  # 127.0.0.1 are still dropped by the kernel (route_localnet is 0).
  systemd.services.docker.environment.DOCKER_INSECURE_NO_IPTABLES_RAW = "1";

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
