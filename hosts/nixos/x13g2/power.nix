{ ... }:

# The lid is left to logind. With another monitor on, chena turns the built-in
# screen off when the lid closes (chena.clamshell in
# users/loutres/home-x13g2.nix), so HandleLidSwitchDocked only has to keep the
# machine running.

{
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    # On AC the machine keeps running with the screen locked, so a build or an
    # SSH session survives closing the lid.
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "ignore";
  };
}
