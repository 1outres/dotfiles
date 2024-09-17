{
  networking = {
    wireguard.interfaces = {
      wg0 = {
        privateKeyFile = "/home/loutres/.config/wgkey";
        peers = [{
          publicKey = "kyNy9VZqg3TFxIvH5t81J609Z937mWq1807UVFtOgnc=";
          endpoint = "36.3.99.131:51820";
          allowedIPs = [ "10.225.0.0/16" "192.168.51.0/24" ];
          persistentKeepalive = 25;
        }];
      };
    };
    firewall = {
      trustedInterfaces = ["wg0"];
    };
  };
}
