{
  lib,
  pkgs,
  ...
}:

let
  palette = import ../catppuccin/palette.nix;
  wallpaper = import ../catppuccin/wallpaper.nix { inherit pkgs palette; };

  # hyprlock reads colours as rgb(RRGGBB) / rgba(RRGGBBAA), the palette stores
  # #RRGGBB.
  rgb = color: "rgb(${lib.removePrefix "#" color})";
  rgba = color: alpha: "rgba(${lib.removePrefix "#" color}${alpha})";

  # hyprlang treats # as the start of a comment, so pango attributes have to
  # spell colours with a doubled hash.
  pango = color: "##${lib.removePrefix "#" color}";
in
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        grace = 0;
        ignore_empty_input = true;
      };

      animations = {
        enabled = true;
        bezier = [ "easeOutQuint, 0.23, 1, 0.32, 1" ];
        animation = [
          "fadeIn, 1, 4, easeOutQuint"
          "inputFieldDots, 1, 2, easeOutQuint"
        ];
      };

      background = [
        {
          path = "${wallpaper}";
          blur_passes = 3;
          blur_size = 8;
          noise = 0.012;
          contrast = 0.9;
          brightness = 0.55;
          vibrancy = 0.17;
          vibrancy_darkness = 0.05;
        }
      ];

      label = [
        {
          text = "$TIME";
          font_family = "JetBrainsMono Nerd Font ExtraBold";
          font_size = 108;
          color = rgb palette.text;
          position = "0, 150";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
          shadow_size = 8;
          shadow_color = rgba palette.crust "cc";
        }
        {
          text = ''cmd[update:60000] date +"%-m月%-d日 %A"'';
          font_family = "Noto Sans CJK JP";
          font_size = 22;
          color = rgb palette.subtext0;
          position = "0, 50";
          halign = "center";
          valign = "center";
          shadow_passes = 1;
          shadow_size = 4;
          shadow_color = rgba palette.crust "aa";
        }
        {
          text = "󰀄  $USER";
          font_family = "JetBrainsMono Nerd Font";
          font_size = 16;
          color = rgb palette.lavender;
          position = "0, -160";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [
        {
          size = "340, 58";
          position = "0, -70";
          halign = "center";
          valign = "center";
          outline_thickness = 2;
          rounding = 29;
          outer_color = rgb palette.mauve;
          inner_color = rgba palette.surface0 "cc";
          font_color = rgb palette.text;
          check_color = rgb palette.sapphire;
          fail_color = rgb palette.red;
          capslock_color = rgb palette.peach;
          placeholder_text = "<span foreground='${pango palette.overlay1}'>󰌾  Password</span>";
          fail_text = "<span foreground='${pango palette.red}'>$FAIL ($ATTEMPTS)</span>";
          dots_size = 0.26;
          dots_spacing = 0.4;
          dots_center = true;
          fade_on_empty = false;
          shadow_passes = 2;
          shadow_size = 6;
          shadow_color = rgba palette.crust "aa";
        }
      ];
    };
  };
}
