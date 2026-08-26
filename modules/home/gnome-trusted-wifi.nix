{
  lib,
  pkgs,
  private,
  ...
}:

# Relaxes GNOME's idle handling while the machine sits on a trusted Wi-Fi
# network. On AC the screen stays on, on battery it still blanks but no longer
# asks for a password, and away from the trusted network everything goes back to
# the normal locking behaviour.
#
# The inhibitor has to be taken from inside the session, because
# org.gnome.SessionManager only accepts it from the session owner. That rules
# out a NetworkManager dispatcher script, which runs as root, so the network is
# watched from a user service instead.
#
# lock-enabled is written with dconf rather than gsettings so the unit does not
# depend on the session's XDG_DATA_DIRS carrying the GNOME schemas.

let
  trustedSsids = private.wifi.trustedSsids;

  inhibitUnit = "gnome-trusted-wifi-inhibit.service";
  lockKey = "/org/gnome/desktop/screensaver/lock-enabled";
  acOnline = "/sys/class/power_supply/AC/online";

  nmcli = "${pkgs.networkmanager}/bin/nmcli";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  stdbuf = "${pkgs.coreutils}/bin/stdbuf";
  dconf = "${pkgs.dconf}/bin/dconf";

  # Falls back to re-reading the network state on a timer, so a missed nmcli
  # event cannot leave the inhibitor held after leaving a trusted network. This
  # also bounds how long an AC to battery switch keeps the screen awake.
  recheckSeconds = 60;

  watcher = pkgs.writeShellScript "gnome-trusted-wifi-watch" ''
    set -euo pipefail

    trusted_ssids=(${lib.escapeShellArgs trustedSsids})

    active_ssids() {
      ${nmcli} -g NAME connection show --active | while IFS= read -r name; do
        if [ -n "$name" ]; then
          ${nmcli} -g 802-11-wireless.ssid connection show id "$name" 2>/dev/null || true
        fi
      done
    }

    on_trusted_network() {
      local ssid trusted
      while IFS= read -r ssid; do
        if [ -z "$ssid" ]; then
          continue
        fi
        for trusted in "''${trusted_ssids[@]}"; do
          if [ "$ssid" = "$trusted" ]; then
            return 0
          fi
        done
      done < <(active_ssids)
      return 1
    }

    on_ac_power() {
      local online=0
      if [ -r ${acOnline} ]; then
        read -r online < ${acOnline}
      fi
      [ "$online" = "1" ]
    }

    set_lock_enabled() {
      local want="$1" current
      current=$(${dconf} read ${lockKey} || true)
      if [ "$current" != "$want" ]; then
        ${dconf} write ${lockKey} "$want"
      fi
    }

    apply() {
      if ! on_trusted_network; then
        ${systemctl} --user stop ${inhibitUnit}
        set_lock_enabled true
      elif on_ac_power; then
        ${systemctl} --user start ${inhibitUnit}
        set_lock_enabled true
      else
        ${systemctl} --user stop ${inhibitUnit}
        set_lock_enabled false
      fi
    }

    apply

    while true; do
      status=0
      IFS= read -r -t ${toString recheckSeconds} _ || status=$?
      if [ "$status" -eq 0 ] || [ "$status" -gt 128 ]; then
        apply
      else
        exit 1
      fi
    done < <(${stdbuf} -oL ${nmcli} monitor)
  '';
in
{
  systemd.user.services.gnome-trusted-wifi-watch = {
    Unit = {
      Description = "Relax GNOME idle handling while on a trusted Wi-Fi network";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${watcher}";
      # Leaving the key behind would keep the session unlocked after the
      # watcher is gone, so the safe value is restored on the way out.
      ExecStopPost = "${dconf} write ${lockKey} true";
      Restart = "always";
      RestartSec = 5;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.gnome-trusted-wifi-inhibit = {
    Unit = {
      Description = "GNOME idle inhibitor held for a trusted Wi-Fi network";
      After = [ "graphical-session.target" ];
      # Stopping or restarting the watcher drops the inhibitor with it, so a
      # dead watcher cannot leave idle handling switched off.
      PartOf = [
        "graphical-session.target"
        "gnome-trusted-wifi-watch.service"
      ];
    };

    Service = {
      ExecStart = builtins.concatStringsSep " " [
        "${pkgs.gnome-session}/bin/gnome-session-inhibit"
        "--inhibit idle"
        "--inhibit-only"
        "--app-id gnome-trusted-wifi"
        "--reason \"Trusted Wi-Fi network\""
      ];
    };
  };
}
