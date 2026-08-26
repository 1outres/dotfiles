{ config, ... }:

{
  imports = [ ./desktop.nix ];

  # polkit / dconf / XWayland / xdg-desktop-portal-gtk と GDM へのセッション
  # 登録は programs.hyprland が面倒を見る。
  programs.hyprland.enable = true;

  # hyprlock は PAM でパスワードを検証する。専用スタックが無いと解錠できない。
  security.pam.services.hyprlock = { };

  # GNOME は fcitx5 を XDG autostart から起動するが、Hyprland は
  # デスクトップ環境ではないので同じ経路が無い。hyprland-session.target
  # (home-manager が作る) に紐付けて、Hyprland セッションでだけ起動する。
  systemd.user.services.fcitx5 = {
    description = "Fcitx5 input method editor";
    bindsTo = [ "hyprland-session.target" ];
    after = [ "hyprland-session.target" ];
    wantedBy = [ "hyprland-session.target" ];
    serviceConfig = {
      ExecStart = "${config.i18n.inputMethod.package}/bin/fcitx5";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
