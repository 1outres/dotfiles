{ ... }:

let
  palette = import ./dracula-palette.nix;
in
{
  services.mako = {
    enable = true;

    settings = {
      font = "JetBrainsMono Nerd Font 11";
      background-color = palette.background;
      text-color = palette.foreground;
      border-color = palette.purple;
      progress-color = "over ${palette.currentLine}";
      border-size = 2;
      border-radius = 8;
      padding = "10";
      margin = "12";
      width = 380;
      default-timeout = 5000;
      anchor = "top-right";

      "urgency=critical" = {
        border-color = palette.red;
        default-timeout = 0;
      };
    };
  };
}
