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

  # DeepSeek Harness Web UI. Like Paseo, browsers come through an external
  # reverse proxy that terminates TLS for dsh.netbird.loutres.me and reaches this
  # host over NetBird. That proxy must have Pass Host Header on and target port
  # 3090. dsh itself listens on loopback only, behind loopbackProxy.
  services.dsh = {
    enable = true;
    user = username;

    loopbackProxy = {
      enable = true;
      listenAddress = private.netbird.homeWslIp;
      publicHost = "dsh.netbird.loutres.me";
      selfAuthenticatedPaths = [ "/remote-serial/agent" ];
    };
  };

  systemd.services.nginx = {
    after = [ "netbird.service" ];
    wants = [ "netbird.service" ];
  };
}
