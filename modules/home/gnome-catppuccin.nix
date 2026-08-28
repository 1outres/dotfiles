{ pkgs, ... }:

# Bring the GNOME session to the same Catppuccin flavour as the Hyprland one.
# The top bar, quick settings and overview take their colours from a Shell
# theme, and only the User Themes extension can install one, so the extension
# is part of this module rather than something to add separately.

let
  palette = import ../catppuccin/palette.nix;
  themes = import ../catppuccin/packages.nix { inherit pkgs; };
  wallpaper = import ../catppuccin/wallpaper.nix { inherit pkgs palette; };
in
{
  imports = [ ./dconf-reload.nix ];

  programs.gnome-shell = {
    enable = true;
    extensions = [ { package = pkgs.gnomeExtensions.user-themes; } ];
  };

  # User Themes reads Shell themes out of ~/.themes, which is not where the
  # home-manager profile puts them.
  home.file.".themes/${themes.gtk.name}".source =
    "${themes.gtk.package}/share/themes/${themes.gtk.name}";

  dconf.settings = {
    # Emptying this key puts the stock Adwaita shell back, which is the way out
    # if a GNOME release moves past what the theme was built for.
    "org/gnome/shell/extensions/user-theme".name = themes.gtk.name;

    # Hyprland 側 (modules/home/hyprpaper.nix) と同じ壁紙を出す。
    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaper}";
      picture-uri-dark = "file://${wallpaper}";
      picture-options = "zoom";
      primary-color = palette.base;
    };

    "org/gnome/desktop/screensaver" = {
      picture-uri = "file://${wallpaper}";
      picture-options = "zoom";
      primary-color = palette.base;
    };

    # libadwaita の強調色。既定の選択肢のうち Mocha の mauve に最も近い。
    "org/gnome/desktop/interface".accent-color = "purple";
  };
}
