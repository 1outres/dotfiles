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
      # Never suspend on idle: with the lid open the machine stays up, and
      # closing the lid is what suspends it.
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "nothing";
      power-button-action = "nothing";
    };
  };
}
