{
  inputs,
  lib,
  pkgs,
  system,
  ...
}:

let
  # ffmpeg-next 8.1.0 in hypr-rdp does not build against FFmpeg 9, which is what
  # pkgs.ffmpeg points at now. Drop this once hypr-rdp uses ffmpeg-next 9.
  hypr-rdp = inputs.hypr-rdp.packages.${system}.hypr-rdp.override {
    ffmpeg = pkgs.ffmpeg_8;
  };

  # systemd の specifier。user service なので %h はそのユーザの home に展開される。
  configFile = "%h/.config/hypr-rdp/config.toml";
in
{
  # config.toml を書くときに --help で選択肢を確認できるようにしておく。
  environment.systemPackages = [ hypr-rdp ];

  networking.firewall.allowedTCPPorts = [ 3389 ];

  # gnome-remote-desktop と同じ 3389 を使うが、こちらは hyprland-session.target
  # にだけ紐付く。GNOME と Hyprland のセッションは同時に動かないので競合しない。
  systemd.user.services.hypr-rdp = {
    description = "Native RDP server for Hyprland";

    bindsTo = [ "hyprland-session.target" ];
    after = [ "hyprland-session.target" ];
    wantedBy = [ "hyprland-session.target" ];

    # 資格情報が無くても hypr-rdp は警告を出すだけで起動してしまう。設定を
    # git や Nix store に置けない以上、ファイルが用意されるまでは起動させず、
    # パスワード無しの 3389 を晒さないようにする。作り方:
    #   install -Dm600 /dev/stdin ~/.config/hypr-rdp/config.toml <<'EOF'
    #   bind = "0.0.0.0:3389"
    #   username = "loutres"
    #   password = "..."
    #   EOF
    unitConfig.ConditionPathExists = configFile;

    serviceConfig = {
      ExecStart = "${lib.getExe hypr-rdp} --config ${configFile}";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
