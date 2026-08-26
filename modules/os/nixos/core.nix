{
  config,
  hostname,
  lib,
  pkgs,
  private,
  username,
  ...
}:

let
  managementUrl = private.netbird.managementUrl;

  # home-nix runs the mNi development endpoints itself; every other host reaches
  # them over the network.
  mniEndpointIp = if hostname == "home-nix" then "127.0.0.1" else private.lan.devHostIp;
in
{
  # Scheduling lives here rather than in modules/shared/nix.nix: `dates` is a
  # NixOS-only option, while nix-darwin schedules the same jobs via `interval`.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise.automatic = true;

  programs.zsh.enable = true;

  # Claude Desktop's SSH remote downloads its own Claude Code build over the
  # connection and runs it on this host. That build asks for the generic
  # /lib64/ld-linux-x86-64.so.2, which NixOS only ships as a stub, so the
  # install step ends with "Couldn't install the Claude CLI on the remote
  # (cli archive)". nix-ld puts a real loader at that path.
  programs.nix-ld.enable = true;

  services.netbird.clients.default = {
    name = "netbird";
    autoStart = true;
    environment = {
      NB_LOG_FILE = "/var/log/netbird/client.log";
      NB_WG_KERNEL_DISABLED = "true";
      NB_MANAGEMENT_URL = managementUrl;
    };
    hardened = false;
    port = 51820;
    ui.enable = lib.mkDefault false;
  };

  # The daemon and the `netbird` CLI are separate processes, so the URL above
  # does not reach an interactive `netbird up`. Without this it has to be passed
  # as `-m` on the first connection of every host.
  environment.sessionVariables.NB_MANAGEMENT_URL = managementUrl;

  # NetBird can push a network route that covers its own management server. The
  # reverse path then points at nb-netbird, so strict filtering drops the
  # server's replies arriving on the physical NIC, and the client can never
  # reconnect after the tunnel goes down.
  networking.firewall.checkReversePath = "loose";

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    # Subnet routes are wanted, but DNS is not: NetBird owns /etc/resolv.conf
    # here, and letting both push resolvers makes lookups depend on start order.
    extraSetFlags = [
      "--accept-routes=true"
      "--accept-dns=false"
    ];
  };

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  virtualisation.docker.enable = true;

  networking.hosts = {
    "${mniEndpointIp}" = private.mni.hostnames;
  };

  environment.systemPackages = [
    pkgs.docker-client
    pkgs.docker-compose
    pkgs.ghostty.terminfo
    pkgs.incus
    pkgs.opentofu
  ];

  users.users.${username} = {
    home = lib.mkDefault "/home/${username}";
    # Append after any host-specific groups. Keep all entries at the same
    # priority: a mkDefault here would be dropped, since list options keep only
    # the highest-precedence definitions and the normal-priority mkAfter wins.
    extraGroups = lib.mkAfter [
      "wheel"
      "docker"
      "netbird"
    ];
    shell = lib.mkDefault pkgs.zsh;
  };

  system.stateVersion = lib.mkDefault "24.11";
}
