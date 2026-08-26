{ ... }:

# Idle behaviour is split between two layers. GNOME owns blanking, locking and
# the power button through dconf, which modules/home/gnome-power.nix sets. The
# lid is left to logind, because GNOME dropped its lid-close settings and has no
# replacement for them.
#
# While a GNOME session runs, gsd-power takes a logind inhibitor for the lid
# whenever a second display is attached, so HandleLidSwitchDocked below mostly
# matters outside the session (GDM, or a console login).

{
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    # On AC the machine keeps running with the screen locked, so a build or an
    # SSH session survives closing the lid.
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore";
    # Matches power-button-action in modules/home/gnome-power.nix, so the button
    # does nothing in the login screen either.
    HandlePowerKey = "ignore";
  };
}
