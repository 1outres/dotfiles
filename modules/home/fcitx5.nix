{ ... }:

# fcitx5 writes the session layout into org.gnome.desktop.input-sources about a
# second after login, so this profile has the last word over
# modules/home/gnome-keyboard.nix and the two have to agree on "us". The
# built-in JIS keyboard gets its printed layout from keyd instead
# (modules/os/nixos/keyd.nix).
#
# The file is managed rather than left to fcitx5 because fcitx5 rewrites it from
# memory on exit: a layout picked up during one session comes back on the next
# login and takes the whole session with it.

{
  home.file.".config/fcitx5/profile" = {
    force = true;
    text = ''
      [Groups/0]
      # Group Name
      Name=Default
      # Layout
      Default Layout=us
      # Default Input Method
      DefaultIM=mozc

      [Groups/0/Items/0]
      # Name
      Name=keyboard-us
      # Layout
      Layout=

      [Groups/0/Items/1]
      # Name
      Name=mozc
      # Layout
      Layout=

      [GroupOrder]
      0=Default
    '';
  };
}
