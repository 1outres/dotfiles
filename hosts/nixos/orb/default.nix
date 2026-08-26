{
  hostname,
  system,
  modulesPath,
  pkgs,
  username,
  ...
}:

{
  imports = [
    "${modulesPath}/virtualisation/lxc-container.nix"
    ./orbstack.nix
    ./memory.nix
    ../../../modules/os/nixos/sshd.nix
  ];

  networking.hostName = hostname;

  nixpkgs.hostPlatform = system;

  security.sudo.wheelNeedsPassword = false;

  users.mutableUsers = false;

  time.timeZone = "Asia/Tokyo";

  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
  };

  systemd.network = {
    enable = true;
    networks."50-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };

    # tailscale の TUN デバイスは networkd の管理対象に入るが対応する
    # .network ファイルがなく pending のままなので、wait-online が
    # タイムアウトして switch が失敗扱いになる。オンライン判定は eth0 だけで足りる。
    wait-online.ignoredInterfaces = [ "tailscale0" ];
  };

  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIICDjCCAbOgAwIBAgIRAKx+RJS3XdhVhR0mneR9DC4wCgYIKoZIzj0EAwIwZjEd
      MBsGA1UEChMUT3JiU3RhY2sgRGV2ZWxvcG1lbnQxHjAcBgNVBAsMFUNvbnRhaW5l
      cnMgJiBTZXJ2aWNlczElMCMGA1UEAxMcT3JiU3RhY2sgRGV2ZWxvcG1lbnQgUm9v
      dCBDQTAeFw0yNjA0MDMxNzQ0MjVaFw0zNjA0MDMxNzQ0MjVaMGYxHTAbBgNVBAoT
      FE9yYlN0YWNrIERldmVsb3BtZW50MR4wHAYDVQQLDBVDb250YWluZXJzICYgU2Vy
      dmljZXMxJTAjBgNVBAMTHE9yYlN0YWNrIERldmVsb3BtZW50IFJvb3QgQ0EwWTAT
      BgcqhkjOPQIBBggqhkjOPQMBBwNCAARSU+/To3Q+/C0nhGc9+ZSQy9kikTLDwoXa
      zBP5tQ4z+K2RMcxSvihj/6t19vYrEodKbX5Scmp0bfgb3D5Eu5bto0IwQDAOBgNV
      HQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUZsZwA3fAxary
      kgUHJo/0ZItC1QIwCgYIKoZIzj0EAwIDSQAwRgIhAMOESbh28SaPaG/vOA82QuaW
      JIlSxm+omxLp5bmFXyMiAiEAmZhwWbPfsoCApyTDF7UBMMd77X1JfoVwabKb8Ugs
      8Z8=
      -----END CERTIFICATE-----
    ''
  ];

  users.users.${username} = {
    uid = 502;
    # wheel/docker/netbird come from modules/os/nixos/core.nix.
    extraGroups = [
      "orbstack"
    ];

    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];

    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];

    # OrbStack keeps the macOS UID aligned inside the guest.
    isSystemUser = true;
    group = "users";
    createHome = true;
    homeMode = "700";
  };

  system.stateVersion = "26.05";
}
