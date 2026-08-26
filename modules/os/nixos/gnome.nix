{ lib, ... }:

{
  imports = [ ./desktop.nix ];

  services.desktopManager.gnome.enable = true;

  # GDM は最後に使ったセッションを覚えるので、これが効くのは初回ログインと
  # autoLogin を有効にしたホストだけ。Hyprland を併用するホストは
  # "hyprland" に上書きする。
  services.displayManager.defaultSession = lib.mkDefault "gnome";
}
