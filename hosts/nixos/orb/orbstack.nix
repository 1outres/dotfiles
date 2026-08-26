{ lib, config, ... }:

{
  environment.shellInit = ''
    . /opt/orbstack-guest/etc/profile-early

    . /opt/orbstack-guest/etc/profile-late

    export ORBSTACK_GUEST=1

    if [ -z "''${SSH_CLIENT-}" ]; then
      export SSH_CLIENT="127.0.0.1 65535 127.0.0.1"
    fi

    if [ -z "''${SSH_CONNECTION-}" ]; then
      export SSH_CONNECTION="127.0.0.1 65535 127.0.0.1 22"
    fi
  '';

  documentation.man.enable = true;
  documentation.doc.enable = true;
  documentation.info.enable = true;

  services.resolved.enable = false;
  networking.resolvconf.enable = false;
  environment.etc."resolv.conf".source = "/opt/orbstack-guest/etc/resolv.conf";

  networking.dhcpcd.extraConfig = ''
    noarp
    noipv6
  '';

  services.openssh.enable = lib.mkDefault false;

  systemd.services."systemd-oomd".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-userdbd".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-udevd".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-timesyncd".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-timedated".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-portabled".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-nspawn@".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-machined".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-localed".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-logind".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-journald@".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-journald".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-journal-remote".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-journal-upload".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-importd".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-hostnamed".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-homed".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-networkd".serviceConfig.WatchdogSec =
    lib.mkIf config.systemd.network.enable 0;

  programs.ssh.extraConfig = ''
    Include /opt/orbstack-guest/etc/ssh_config
  '';

  nix.settings.extra-platforms = [
    "x86_64-linux"
    "i686-linux"
  ];

  users.groups.orbstack.gid = 67278;
}
