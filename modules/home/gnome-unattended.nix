{ lib, ... }:

# For a machine that runs on its own and is reached by remote desktop: a screen
# lock or an idle suspend would make it unreachable. A desktop someone sits in
# front of wants the opposite, so this is not part of the shared GNOME modules.
#
# These have to be written into the user's own dconf database. A system database
# sits below it in /etc/dconf/profile/user, and GNOME writes these keys into the
# user database itself, so a system default would never be read.

{
  imports = [ ./dconf-reload.nix ];

  dconf.settings = {
    "org/gnome/desktop/screensaver" = {
      lock-enabled = false;
      idle-activation-enabled = false;
    };

    "org/gnome/desktop/session" = {
      idle-delay = lib.gvariant.mkUint32 0;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "nothing";
      idle-dim = false;
    };
  };
}
