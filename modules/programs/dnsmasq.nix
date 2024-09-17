{
  services.dnsmasq = {
    enable = true;
    settings.server = [
      "/loutres.internal/10.225.3.1"
      "/loutres.internal/10.225.3.2"
    ];
  };
}
