# One place to pick the flavour and accent. Every module that draws something
# — toolkits, GNOME Shell, the boot splash, the input method — takes its
# package and theme name from here, so the whole machine moves together.
{ pkgs }:

let
  flavor = "mocha";
  accent = "mauve";
in
{
  gtk = {
    package = pkgs.catppuccin-gtk.override {
      accents = [ accent ];
      size = "standard";
      variant = flavor;
    };
    name = "catppuccin-${flavor}-${accent}-standard";
  };

  icons = {
    package = pkgs.catppuccin-papirus-folders.override { inherit flavor accent; };
    name = "Papirus-Dark";
  };

  cursors = {
    # The attribute is camel-cased upstream, so it cannot be built from the
    # names above.
    package = pkgs.catppuccin-cursors.mochaMauve;
    name = "catppuccin-${flavor}-${accent}-cursors";
    size = 24;
  };

  fcitx5 = {
    package = pkgs.catppuccin-fcitx5;
    name = "catppuccin-${flavor}-${accent}";
  };
}
