{
  config,
  lib,
  pkgs,
  ...
}:

let
  palette = import ./dracula-palette.nix;

  # Hyprland wants rgba(RRGGBBAA), the palette stores #RRGGBB.
  rgba = color: alpha: "rgba(${lib.removePrefix "#" color}${alpha})";

  terminal = lib.getExe config.programs.ghostty.package;
  launcher = "${lib.getExe pkgs.wofi} --show drun";
  fileManager = lib.getExe pkgs.nautilus;
  lock = lib.getExe config.programs.hyprlock.package;

  wpctl = lib.getExe' pkgs.wireplumber "wpctl";
  wlCopy = lib.getExe' pkgs.wl-clipboard "wl-copy";
  screenshotRegion = ''${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${wlCopy}'';
  screenshotScreen = "${lib.getExe pkgs.grim} - | ${wlCopy}";

  workspaceBinds = builtins.concatLists (
    builtins.genList (
      i:
      let
        workspace = toString (i + 1);
        key = if i == 9 then "0" else workspace;
      in
      [
        "$mod, ${key}, workspace, ${workspace}"
        "$mod SHIFT, ${key}, movetoworkspace, ${workspace}"
      ]
    ) 10
  );
in
{
  # waybar や hyprpolkitagent の既定の起動先は graphical-session.target で、
  # そのままだと GNOME セッションでも起動してしまう。Hyprland 専用の
  # target に寄せて、二つのセッションを混ぜない。
  wayland.systemd.target = "hyprland-session.target";

  # GUI から権限昇格を求められたときのプロンプト。GNOME では gnome-shell が
  # 担うが、Hyprland には無いので明示的に立てる。
  services.hyprpolkitagent.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;

    # compositor と portal の実体は NixOS 側の programs.hyprland が入れる。
    # ここで package を持つと二重に別ビルドを抱えることになる。
    package = null;
    portalPackage = null;

    # home.stateVersion 26.05 以降は既定が "lua" に変わる。生成される設定の
    # 形式を stateVersion に引きずられないよう固定する。
    configType = "hyprlang";

    settings = {
      "$mod" = "SUPER";

      monitor = ",preferred,auto,1";

      env = [
        "XCURSOR_SIZE,24"
        "NIXOS_OZONE_WL,1"
      ];

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "${rgba palette.purple "ee"} ${rgba palette.pink "ee"} 45deg";
        "col.inactive_border" = rgba palette.currentLine "aa";
        layout = "dwindle";
      };

      # VMware の SVGA3D は LLVM のソフトウェアパスで動くので、ぼかしと影は
      # そのままフレームレートに跳ね返る。RDP 越しの体感も悪くなるため切る。
      decoration = {
        rounding = 6;
        blur.enabled = false;
        shadow.enabled = false;
      };

      animations.enabled = false;

      dwindle.preserve_split = true;

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad.natural_scroll = false;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      bind = [
        "$mod, Return, exec, ${terminal}"
        "$mod, Q, killactive,"
        "$mod, E, exec, ${fileManager}"
        "$mod, R, exec, ${launcher}"
        "$mod, X, exec, ${lock}"
        "$mod, F, fullscreen, 0"
        "$mod, V, togglefloating,"
        "$mod, P, pseudo,"
        "$mod, T, layoutmsg, togglesplit"
        "$mod SHIFT, Q, exit,"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        ", Print, exec, ${screenshotScreen}"
        "SHIFT, Print, exec, ${screenshotRegion}"
      ]
      ++ workspaceBinds;

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
    };
  };

  home.packages = [
    pkgs.grim
    pkgs.nautilus
    pkgs.slurp
    pkgs.wl-clipboard
  ];
}
