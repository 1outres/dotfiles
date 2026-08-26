{ lib, ... }:

# A GNOME session on Wayland takes its layout from this dconf key and ignores
# services.xserver.xkb, and gsd already wrote "us" into the user database, so a
# system-wide default cannot win either.
#
# The session stays on "us" even where the built-in keyboard is JIS. Mutter has
# no per-device input source, so one layout has to serve every keyboard, and the
# built-in board is remapped to its printed layout by keyd instead
# (modules/os/nixos/keyd.nix).
#
# mru-sources is pinned as well. GNOME rebuilds sources from it, so a stale
# entry there puts the old layout back on its own, long after activation ran.

{
  imports = [ ./dconf-reload.nix ];

  dconf.settings."org/gnome/desktop/input-sources" = {
    sources = [ (lib.gvariant.mkTuple [ "xkb" "us" ]) ];
    mru-sources = [ (lib.gvariant.mkTuple [ "xkb" "us" ]) ];
    xkb-options = [ "ctrl:nocaps" ];
  };
}
