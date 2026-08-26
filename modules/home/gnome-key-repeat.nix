{ lib, ... }:

# The two values are what macOS repeats at on its fastest setting: 225 ms
# before the repeat starts and 30 ms between repeats. GNOME waits 500 ms, which
# is long enough that a held key reads as ignored.

{
  imports = [ ./dconf-reload.nix ];

  dconf.settings."org/gnome/desktop/peripherals/keyboard" = {
    delay = lib.gvariant.mkUint32 225;
    repeat-interval = lib.gvariant.mkUint32 30;
  };
}
