{
  inputs,
  private,
  username,
  ...
}:

{
  imports = [
    inputs.self.nixosModules.dsh
  ];

  # DeepSeek Harness Web UI, used from the Mac over NetBird. It listens only on
  # this host's NetBird address, so the LAN cannot reach it. It speaks plain
  # HTTP inside the WireGuard tunnel; the launch token and the session cookie
  # authenticate the browser.
  services.dsh = {
    enable = true;
    user = username;
    host = private.netbird.homeWslIp;
  };

  systemd.services.dsh = {
    after = [ "netbird.service" ];
    wants = [ "netbird.service" ];
  };
}
