{ config, lib, ... }:

let
  palette = import ./dracula-palette.nix;
in
{
  programs.wofi = {
    enable = true;

    settings = {
      show = "drun";
      width = 600;
      height = 400;
      prompt = "";
      insensitive = true;
      hide_scroll = true;
      term = lib.getExe config.programs.ghostty.package;
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Noto Sans CJK JP", sans-serif;
        font-size: 14px;
      }

      window {
        background-color: ${palette.background};
        border: 2px solid ${palette.purple};
        border-radius: 8px;
      }

      #input {
        margin: 8px;
        padding: 6px;
        color: ${palette.foreground};
        background-color: ${palette.currentLine};
        border: none;
        border-radius: 6px;
      }

      #inner-box,
      #outer-box,
      #scroll {
        background-color: transparent;
      }

      #outer-box {
        margin: 8px;
      }

      #entry {
        padding: 6px;
        border-radius: 6px;
      }

      #entry:selected {
        background-color: ${palette.purple};
      }

      #text {
        color: ${palette.foreground};
      }

      #entry:selected #text {
        color: ${palette.background};
      }
    '';
  };
}
