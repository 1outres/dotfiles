{ lib, theme, ... }:
{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "ALT";
    bind = [
      "$mainMod, C, killactive, "
      "$mainMod, Q, exec, alacritty"
      "$mainMod SHIFT, M, exit, "
      "$mainMod, Space, exec, wofi --show drun"

      "$mainMod SHIFT, J, togglesplit"

      "$mainMod, H, movefocus, l"
      "$mainMod, L, movefocus, r"
      "$mainMod, K, movefocus, u"
      "$mainMod, J, movefocus, d"

      "$mainMod, 1, split-workspace, 1"
      "$mainMod, 2, split-workspace, 2"
      "$mainMod, 3, split-workspace, 3"
      "$mainMod, 4, split-workspace, 4"
      "$mainMod, 5, split-workspace, 5"
      "$mainMod, 6, split-workspace, 6"
      "$mainMod, 7, split-workspace, 7"
      "$mainMod, 8, split-workspace, 8"
      "$mainMod, 9, split-workspace, 9"

      "$mainMod SHIFT, 1, split-movetoworkspace, 1"
      "$mainMod SHIFT, 2, split-movetoworkspace, 2"
      "$mainMod SHIFT, 3, split-movetoworkspace, 3"
      "$mainMod SHIFT, 4, split-movetoworkspace, 4"
      "$mainMod SHIFT, 5, split-movetoworkspace, 5"
      "$mainMod SHIFT, 6, split-movetoworkspace, 6"
      "$mainMod SHIFT, 7, split-movetoworkspace, 7"
      "$mainMod SHIFT, 8, split-movetoworkspace, 8"
      "$mainMod SHIFT, 9, split-movetoworkspace, 9"

      "$mainMod SHIFT, H, movewindow, l"
      "$mainMod SHIFT, L, movewindow, r"
      "$mainMod SHIFT, K, movewindow, u"
      "$mainMod SHIFT, J, movewindow, d"

      "$mainMod, T, togglefloating"

      "$mainMod, F, fullscreen"
      "$mainMod CTRL, L, exec, swaylock"
      "$mainMod SHIFT, S, exec, /home/loutres/.bin/grimshot"
    ];
    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];
  };
}
