{ ... }:

let
  palette = import ./dracula-palette.nix;

  # hyprlock reads colors as rgb(RRGGBB), the palette stores #RRGGBB.
  rgb = color: "rgb(${builtins.substring 1 6 color})";
in
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        grace = 0;
      };

      background = [
        {
          color = rgb palette.background;
        }
      ];

      input-field = [
        {
          size = "300, 50";
          position = "0, -20";
          halign = "center";
          valign = "center";
          outline_thickness = 2;
          rounding = 8;
          outer_color = rgb palette.purple;
          inner_color = rgb palette.currentLine;
          font_color = rgb palette.foreground;
          check_color = rgb palette.cyan;
          fail_color = rgb palette.red;
          placeholder_text = "";
          fade_on_empty = false;
        }
      ];

      label = [
        {
          text = "$TIME";
          font_size = 64;
          font_family = "JetBrainsMono Nerd Font";
          color = rgb palette.foreground;
          position = "0, 120";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
