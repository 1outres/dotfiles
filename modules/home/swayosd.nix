{ lib, pkgs, ... }:

let
  palette = import ../catppuccin/palette.nix;

  style = pkgs.writeText "swayosd.css" ''
    window#osd {
      padding: 0;
      margin: 0;
      border-radius: 22px;
      border: 1px solid ${palette.surface1};
      background: alpha(${palette.base}, 0.82);
    }

    window#osd #container {
      margin: 18px;
    }

    window#osd image,
    window#osd label {
      color: ${palette.text};
    }

    window#osd progressbar:disabled,
    window#osd image:disabled {
      opacity: 0.4;
    }

    window#osd progressbar {
      min-height: 6px;
      border-radius: 999px;
      background: transparent;
    }

    window#osd trough {
      min-height: inherit;
      border-radius: inherit;
      border: none;
      background: ${palette.surface0};
    }

    window#osd progress {
      min-height: inherit;
      border-radius: inherit;
      border: none;
      background: ${palette.mauve};
    }
  '';
in
{
  services.swayosd = {
    enable = true;
    # 画面の下寄り。ウィンドウの中身にかぶりにくい。
    topMargin = 0.85;
    stylePath = style;
  };

  home.packages = [ pkgs.brightnessctl ];
}
