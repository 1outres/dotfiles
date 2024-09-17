{ config, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.tailscale ];
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };
  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
  };

  networking.interfaces.tailscale0.ipv4.routes = [
  {
    address = "192.168.115.0";
    prefixLength = 24;
  }
  ];
}
