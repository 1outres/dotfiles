{ lib, pkgs, ... }:

# Widget toolkits, icons, the cursor and the input method popup, all pinned to
# the same Catppuccin flavour the compositor uses. GTK settings land in dconf
# as well, so a GNOME session on the same machine picks up the theme too.

let
  themes = import ../catppuccin/packages.nix { inherit pkgs; };
in
{
  imports = [ ./dconf-reload.nix ];

  gtk = {
    enable = true;

    theme = {
      inherit (themes.gtk) package name;
    };

    # catppuccin-gtk ships a gtk-4.0 stylesheet, so GTK4 gets the same theme
    # rather than home-manager's newer default of leaving it unset.
    gtk4.theme = {
      inherit (themes.gtk) package name;
    };

    iconTheme = {
      inherit (themes.icons) package name;
    };

    font = {
      name = "Noto Sans CJK JP";
      size = 11;
    };

    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  home.pointerCursor = {
    enable = true;
    inherit (themes.cursors) package name size;
    gtk.enable = true;
    x11.enable = true;
  };

  # GTK3 統合を通すと、Qt アプリもここで決めたテーマ・フォント・ファイル
  # ピッカーを共有する。
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  # Hyprland は hyprcursor 形式を先に探し、無ければ XCursor を読む。
  # catppuccin-cursors は両方を同じ名前で入れるので、名前だけ渡せば足りる。
  wayland.windowManager.hyprland.settings.env = [
    "HYPRCURSOR_THEME,${themes.cursors.name}"
    "HYPRCURSOR_SIZE,${toString themes.cursors.size}"
    "XCURSOR_THEME,${themes.cursors.name}"
    "XCURSOR_SIZE,${toString themes.cursors.size}"
  ];

  xdg.dataFile."fcitx5/themes".source = "${themes.fcitx5.package}/share/fcitx5/themes";

  # fcitx5 rewrites its own configuration from memory when it exits, so this
  # file has to be managed the same way modules/home/fcitx5.nix manages the
  # profile: a theme picked up during one session would come back otherwise.
  xdg.configFile."fcitx5/conf/classicui.conf" = {
    force = true;
    text = ''
      Theme=${themes.fcitx5.name}
      DarkTheme=${themes.fcitx5.name}
      UseDarkTheme=False
      UseAccentColor=False
      Font="Noto Sans CJK JP 11"
      MenuFont="Noto Sans CJK JP 11"
      TrayFont="Noto Sans CJK JP Bold 11"
    '';
  };

  # libadwaita のアプリは GTK テーマを読まないので、暗い配色はこのキーで伝える。
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  programs.ghostty.settings.theme = lib.mkForce "Catppuccin Mocha";
}
