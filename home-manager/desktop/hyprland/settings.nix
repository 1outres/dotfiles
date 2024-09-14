{ lib, theme, ... }:
{
  wayland.windowManager.hyprland.settings = {
    env = [
      "QT_QPA_PLATFORMTHEME, qt6ct"
    ];
    exec-once = [
      "mako"
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "waybar"
      "swaybg -m fill -i ~/.config/hypr/bg.png"
      "xdg-portal-hyprland"
      "fcitx5"
      "hyprpm reload"
    ];
    exec = [
      "gsettings set org.gnome.desktop.interface gtk-theme \"YOUR_DARK_GTK3_THEME\""
      "gsettings set org.gnome.desktop.interface color-scheme \"prefer-dark\""
    ];
    windowrulev2 = [
      "opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$"
      "noanim,class:^(xwaylandvideobridge)$"
      "nofocus,class:^(xwaylandvideobridge)$"
      "noinitialfocus,class:^(xwaylandvideobridge)$"

      "nofocus,class:^(mozc_renderer)$"
      "noinitialfocus,class:^(mozc_renderer)$"
      "noanim,class:^(mozc_renderer)$"
      "float,class:^(mozc_renderer)$"
    ];
    input = {
      kb_layout = "us";
      kb_options = "ctrl:nocaps";
      touchpad = {
        natural_scroll = false;
        scroll_factor = 0.1;
        tap-to-click = false;
        clickfinger_behavior = true;
      };
      sensitivity = -0.2;
    };
    general = {
      gaps_in = 5;
      gaps_out = 20;
      border_size = 2;
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = "rgba(595959aa)";
      layout = "dwindle";
    };
    decoration = {
      rounding = 10;
      blur = {
        enabled = true;
        size = 3;
        passes = 1;
        new_optimizations = true;
      };
      drop_shadow = true;
      shadow_range = 4;
      shadow_render_power = 3;
      "col.shadow" = "rgba(1a1a1aee)";
    };
    animations = {
      enabled = true;
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
      ];
    };
    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };
    master = {
      new_status = "master";
    };
    gestures = {
      workspace_swipe = "off";
    };
  };
}
