{ pkgs, ... }:

let
  palette = import ../catppuccin/palette.nix;
  wallpaper = import ../catppuccin/wallpaper.nix { inherit pkgs palette; };
in
{
  services.hyprpaper = {
    enable = true;

    settings = {
      # 壁紙は一枚きりで切り替えないので、待ち受ける相手がいない。
      ipc = "off";
      splash = false;

      preload = [ "${wallpaper}" ];
      wallpaper = [ ",${wallpaper}" ];
    };
  };
}
