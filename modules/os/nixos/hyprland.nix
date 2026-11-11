{
  pkgs,
  username,
  ...
}:

{
  imports = [
    ./desktop.nix
    ./fcitx5-hyprland.nix
  ];

  # polkit / dconf / XWayland / xdg-desktop-portal-gtk と GDM へのセッション
  # 登録は programs.hyprland が面倒を見る。
  programs.hyprland.enable = true;

  # hyprlock は PAM でパスワードを検証する。専用スタックが無いと解錠できない。
  security.pam.services.hyprlock = { };

  # 輝度キーは brightnessctl と swayosd が sysfs に直接書いて実現する。両者の
  # udev ルールが backlight を video グループへ開放し、swayosd の polkit
  # アクションはシステムのプロファイルからしか読まれないので、ユーザの
  # home.packages ではなくここに置く。
  services.udev.packages = [
    pkgs.brightnessctl
    pkgs.swayosd
  ];
  environment.systemPackages = [ pkgs.swayosd ];
  users.users.${username}.extraGroups = [ "video" ];

  # waybar の Bluetooth モジュールが読む先。GNOME では gnome-settings-daemon
  # が同じ役目を負う。
  services.blueman.enable = true;
}
