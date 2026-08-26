{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  tlsDir = "/var/lib/gnome-remote-desktop-tls";
  tlsCert = "${tlsDir}/rdp.crt";
  tlsKey = "${tlsDir}/rdp.key";
in
{
  # services.desktopManager.gnome.enable が mkDefault true にするが、
  # 依存を明示するためここで固定する。
  services.gnome.gnome-remote-desktop.enable = true;

  networking.firewall.allowedTCPPorts = [ 3389 ];

  # パッケージ同梱の user unit は systemd.packages でリンクされるだけで
  # gnome-session.target に紐付かず、D-Bus activation の口も無い。
  # drop-in で自動起動を足さないとログインのたび手動起動が要る。
  systemd.user.services.gnome-remote-desktop = {
    overrideStrategy = "asDropin";
    wantedBy = [ "gnome-session.target" ];
  };

  systemd.tmpfiles.settings."10-gnome-remote-desktop-tls".${tlsDir}.d = {
    user = username;
    group = "users";
    mode = "0700";
  };

  # RDP の TLS 証明書はパッケージにも NixOS モジュールにも同梱されないため、
  # ユーザモードの daemon が読める自己署名を一度だけ生成する。
  systemd.services.gnome-remote-desktop-tls-cert = {
    description = "Generate self-signed TLS certificate for GNOME Remote Desktop";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-tmpfiles-setup.service" ];
    unitConfig.ConditionPathExists = "!${tlsKey}";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = username;
      Group = "users";
      UMask = "0077";
    };
    script = ''
      ${lib.getExe pkgs.openssl} req -x509 -newkey rsa:4096 -noenc \
        -keyout ${tlsKey} -out ${tlsCert} \
        -days 3650 \
        -subj "/CN=${config.networking.hostName}" \
        -addext "subjectAltName=DNS:${config.networking.hostName}"
    '';
  };

  # デスクトップ共有 (ログイン中のセッションを共有するユーザモード)。
  # 接続用の資格情報のみ gnome-keyring 管理のため宣言できない:
  #   grdctl rdp set-credentials <username> <password>
  programs.dconf.profiles.user.databases = [
    {
      # Without locks the user database wins over this one, and both grdctl and
      # the Remote Desktop panel write there, so every key below would be a
      # default that nothing reads.
      lockAll = true;

      settings = {
        "org/gnome/desktop/remote-desktop/rdp" = {
          enable = true;
          view-only = false;
          # extend (仮想モニタ増設) は mutter 18 の
          # meta_virtual_monitor_get_crtc_mode で SEGV し、接続のたび
          # gnome-shell ごとセッションが落ちる。物理ディスプレイのミラーに固定する。
          screen-share-mode = "mirror-primary";
          port = lib.gvariant.mkUint16 3389;
          # ファイアウォールは 3389 のみ開けるので、別ポートへの退避を禁じる。
          negotiate-port = false;
          tls-cert = tlsCert;
          tls-key = tlsKey;
        };

        # ロック画面が出ている間 mutter は CreateSession を
        # "Session creation inhibited" で拒否し、リモートから復帰できなくなる。
        # gnome.nix の lock-enabled = false はパスワード要求を消すだけで
        # シールド自体の表示は止まらないため、ロック画面ごと無効化する。
        "org/gnome/desktop/lockdown" = {
          disable-lock-screen = true;
        };
      };
    }
  ];
}
