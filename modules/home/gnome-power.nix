{ lib, ... }:

# These have to be written into the user's own dconf database. A system
# database sits below it in /etc/dconf/profile/user, and GNOME has already
# written every one of these keys into the user database, so a system default
# would never be read.

{
  imports = [ ./dconf-reload.nix ];

  dconf.settings = {
    "org/gnome/desktop/session" = {
      idle-delay = lib.gvariant.mkUint32 60;
    };

    "org/gnome/desktop/screensaver" = {
      idle-activation-enabled = true;
      lock-enabled = true;
      lock-delay = lib.gvariant.mkUint32 0;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      # On AC the machine stays up with the lid open, so a build or an SSH
      # session survives an empty desk. On battery there is nothing worth
      # keeping alive, so it suspends instead of spending the charge.
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "suspend";
      sleep-inactive-battery-timeout = 900;
      power-button-action = "nothing";
    };
  };
}
