{
  config,
  lib,
  pkgs,
  ...
}:

let
  palette = import ../catppuccin/palette.nix;

  # Hyprland wants rgba(RRGGBBAA), the palette stores #RRGGBB.
  rgba = color: alpha: "rgba(${lib.removePrefix "#" color}${alpha})";

  terminal = lib.getExe config.programs.ghostty.package;
  fileManager = lib.getExe pkgs.nautilus;
  lock = lib.getExe config.programs.hyprlock.package;

  vicinae = "${pkgs.vicinae}/bin/vicinae";
  launcher = "${vicinae} toggle";
  clipboardHistory = "${vicinae} deeplink vicinae://launch/clipboard/history";

  osd = lib.getExe' pkgs.swayosd "swayosd-client";
  notificationCentre = "${lib.getExe' pkgs.swaynotificationcenter "swaync-client"} --toggle-panel";
  colorPicker = lib.getExe pkgs.hyprpicker;

  screenshot = mode: "${lib.getExe pkgs.hyprshot} --freeze --clipboard-only --mode ${mode}";

  cycleAppWindows = pkgs.writeShellApplication {
    name = "hypr-cycle-app-windows";
    runtimeInputs = [ pkgs.jq ];
    text = builtins.readFile ./assets/cycle-app-windows.sh;
  };
  cycleApp = direction: "${lib.getExe cycleAppWindows} ${direction}";

  lidMonitor = pkgs.writeShellApplication {
    name = "hypr-lid-monitor";
    runtimeInputs = [ pkgs.jq ];
    text = builtins.readFile ./assets/lid-monitor.sh;
  };

  # Layers the compositor blurs behind. The namespace is what each client sets
  # on its layer surface, read back with `hyprctl layers`.
  blurredLayers = [
    "waybar"
    "swaync-control-center"
    "swaync-notification-window"
    "vicinae"
    "swayosd"
  ];

  # Since 0.56 a rule is a comma separated list of "<field> <value>" pairs, and
  # a matcher carries a match: prefix. ignore_alpha keeps fully transparent
  # padding out of the blur, so the edge of a rounded island stays clean.
  blurLayerRules = builtins.concatMap (namespace: [
    "blur 1, match:namespace ^(${namespace})$"
    "ignore_alpha 0, match:namespace ^(${namespace})$"
  ]) blurredLayers;

  splitMonitorWorkspaces = import ./assets/split-monitor-workspaces.nix { inherit pkgs; };

  powerMenu = lib.getExe pkgs.wlogout;

  workspaceKeys = import ./assets/workspaces.nix;

  # split-workspace が指すのは「今フォーカスしているモニタの n 番目」で、
  # 番号は画面ごとに独立する。外部モニタでも同じ指が使える。
  workspaceBinds = builtins.concatLists (
    lib.imap1 (index: key: [
      "$wm, ${key}, split-workspace, ${toString index}"
      "$wm SHIFT, ${key}, split-movetoworkspace, ${toString index}"
    ]) workspaceKeys
  );
in
{
  imports = [
    ./catppuccin-theme.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./swaync.nix
    ./swayosd.nix
    ./waybar.nix
    ./wlogout.nix
  ];

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

    plugins = [ splitMonitorWorkspaces ];

    settings = {
      "$mod" = "SUPER";
      # SUPER はアプリとシステム、ALT はウィンドウマネージャの操作。
      "$wm" = "ALT";

      monitor = ",preferred,auto,1";

      env = [
        "NIXOS_OZONE_WL,1"
      ];

      # 蓋を閉じたまま Hyprland に入ることがあるのと、設定を読み直すたびに
      # monitor が再適用されて内蔵パネルが戻ってくるので、起動時だけの
      # exec-once ではなく exec で毎回合わせ直す。
      exec = [ "${lib.getExe lidMonitor} sync" ];

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" =
          "${rgba palette.mauve "ff"} ${rgba palette.pink "ff"} ${rgba palette.sapphire "ff"} 45deg";
        "col.inactive_border" = rgba palette.surface0 "aa";
        layout = "dwindle";
        resize_on_border = true;
        allow_tearing = false;
        snap.enabled = true;
      };

      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 0.95;
        fullscreen_opacity = 1.0;
        dim_inactive = true;
        dim_strength = 0.08;

        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = true;
          # ウィンドウ自身の透過を無視してぼかす。Ghostty は
          # background-opacity 0.8 なので、これが無いと背景が素通しになる。
          ignore_opacity = true;
          noise = 0.012;
          contrast = 1.1;
          brightness = 0.85;
          vibrancy = 0.18;
          vibrancy_darkness = 0.05;
          popups = true;
          popups_ignorealpha = 0.4;
          input_methods = true;
        };

        shadow = {
          enabled = true;
          range = 24;
          render_power = 3;
          color = rgba palette.crust "aa";
          color_inactive = rgba palette.crust "55";
          offset = "0 4";
          scale = 0.97;
        };

        # 0.56 で入った縁の発光。フォーカスされたウィンドウだけが
        # アクセント色に光る。
        glow = {
          enabled = true;
          range = 14;
          render_power = 2;
          color = rgba palette.mauve "55";
          color_inactive = rgba palette.crust "00";
        };
      };

      animations = {
        enabled = true;

        bezier = [
          "easeOutQuint, 0.23, 1, 0.32, 1"
          "easeInOutCubic, 0.65, 0.05, 0.36, 1"
          "linear, 0, 0, 1, 1"
          "almostLinear, 0.5, 0.5, 0.75, 1"
          "quick, 0.15, 0, 0.1, 1"
        ];

        animation = [
          "global, 1, 8, default"
          "border, 1, 5.4, easeOutQuint"
          "windows, 1, 4.8, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.5, linear, popin 87%"
          "fadeIn, 1, 1.7, almostLinear"
          "fadeOut, 1, 1.5, almostLinear"
          "fade, 1, 3, quick"
          "layers, 1, 3.8, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.8, almostLinear"
          "fadeLayersOut, 1, 1.4, almostLinear"
          "workspaces, 1, 1.9, almostLinear, fade"
          "specialWorkspace, 1, 3, easeOutQuint, slidevert"
        ];
      };

      dwindle = {
        preserve_split = true;
        smart_resizing = true;
      };

      group = {
        "col.border_active" = "${rgba palette.mauve "ff"} ${rgba palette.sapphire "ff"} 45deg";
        "col.border_inactive" = rgba palette.surface0 "aa";

        groupbar = {
          enabled = true;
          font_family = "JetBrainsMono Nerd Font";
          font_size = 11;
          height = 22;
          rounding = 8;
          gradients = true;
          gradient_rounding = 6;
          indicator_height = 3;
          text_color = rgba palette.text "ff";
          text_color_inactive = rgba palette.overlay1 "ff";
          "col.active" = rgba palette.mauve "ff";
          "col.inactive" = rgba palette.surface0 "cc";
        };
      };

      input = {
        kb_layout = "us";
        # keyd (modules/os/nixos/keyd.nix) は内蔵 JIS を印字通りに直すだけで、
        # CapsLock の入れ替えまではしない。GNOME 側は dconf の xkb-options が
        # 担うが、Hyprland は自前の xkb 設定を持つのでここにも要る。
        kb_options = "ctrl:nocaps";

        # macOS の最速設定と同じ間隔。GNOME 側は
        # modules/home/gnome-key-repeat.nix が同じ値を入れている。
        repeat_delay = 225;
        repeat_rate = 33;

        follow_mouse = 1;

        # GNOME 側 (org.gnome.desktop.peripherals) と同じ向きに揃える。
        natural_scroll = true;

        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
          tap-and-drag = true;
          drag_lock = true;
        };
      };

      gesture = [
        "3, horizontal, workspace"
        "4, up, special"
      ];

      gestures = {
        workspace_swipe_distance = 320;
        workspace_swipe_cancel_ratio = 0.35;
      };

      cursor = {
        enable_hyprcursor = true;
        hide_on_key_press = true;
        inactive_timeout = 5;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
        background_color = rgba palette.crust "ff";
        focus_on_activate = true;
        # ドラッグ中まで補間すると入力が遅れて感じられる。
        animate_manual_resizes = false;
        animate_mouse_windowdragging = false;
        # hyprlock が出ている間もぼかしを効かせる。
        session_lock_blur = true;
      };

      layerrule = blurLayerRules;

      windowrule = [
        # Electron や一部の GTK アプリが起動直後に投げる maximize 要求で
        # タイル配置が崩れるのを止める。
        "suppress_event maximize, match:class .*"

        "float 1, match:class ^(pavucontrol|nm-connection-editor|blueman-manager)$"
        "float 1, match:class ^(org.gnome.Calculator|org.gnome.FileRoller)$"
        "float 1, match:class ^(1Password)$"
        "float 1, match:title ^(Picture-in-Picture)$"
        "pin 1, match:title ^(Picture-in-Picture)$"
        "size 640 360, match:title ^(Picture-in-Picture)$"
        "move 100%-660 100%-420, match:title ^(Picture-in-Picture)$"

        # 1Password の中身がぼかし越しに透けないようにする。
        "no_blur 1, match:class ^(1Password)$"
        "no_screen_share 1, match:class ^(1Password)$"
      ];

      workspace = [
        "special:magic, gapsout:60, on-created-empty:${terminal}"
      ];

      plugin."split-monitor-workspaces" = {
        count = builtins.length workspaceKeys;
        # 起動時に各モニタへ 9 つ並べておくと、waybar のワークスペース欄が
        # 常に同じ幅になる。
        enable_persistent_workspaces = 1;
        enable_notifications = 0;
        keep_focused = 0;
      };

      bind = [
        "$mod, Q, exec, ${terminal}"
        "$mod, W, killactive,"
        "$mod, F, fullscreen, 0"
        "$mod, L, exec, ${lock}"
        "$mod, Space, exec, ${launcher}"
        "$mod, E, exec, ${fileManager}"
        "$mod, N, exec, ${notificationCentre}"
        "$mod, P, exec, ${colorPicker} --autocopy"
        "$mod, Escape, exec, ${powerMenu}"
        "$mod SHIFT, S, exec, ${screenshot "region"}"
        "$mod SHIFT, M, exit,"

        # クリップボード履歴。GNOME 側 (modules/home/vicinae.nix) と同じ指に
        # なるよう ALT に置く。
        "ALT, Space, exec, ${clipboardHistory}"

        "$wm, H, movefocus, l"
        "$wm, J, movefocus, d"
        "$wm, K, movefocus, u"
        "$wm, L, movefocus, r"

        "$wm SHIFT, H, movewindow, l"
        "$wm SHIFT, J, movewindow, d"
        "$wm SHIFT, K, movewindow, u"
        "$wm SHIFT, L, movewindow, r"

        "$wm, T, togglefloating,"
        "$wm, B, layoutmsg, togglesplit"
        "$wm, P, pseudo,"
        "$wm, I, centerwindow,"
        "$wm, G, togglegroup,"
        "$wm, Tab, changegroupactive, f"
        "$wm SHIFT, Tab, changegroupactive, b"
        "$wm, A, togglespecialworkspace, magic"
        "$wm SHIFT, A, movetoworkspace, special:magic"

        # macOS の Cmd+` と同じく、同じアプリのウィンドウだけを巡る。
        "$wm, grave, exec, ${cycleApp "next"}"
        "$wm SHIFT, grave, exec, ${cycleApp "prev"}"

        "$wm, left, split-cycleworkspaces, -1"
        "$wm, right, split-cycleworkspaces, +1"

        ", Print, exec, ${screenshot "region"}"
        "SHIFT, Print, exec, ${screenshot "output"}"
        "$mod, Print, exec, ${screenshot "window"}"
      ]
      ++ workspaceBinds;

      binde = [
        "$wm CTRL, H, resizeactive, -40 0"
        "$wm CTRL, J, resizeactive, 0 40"
        "$wm CTRL, K, resizeactive, 0 -40"
        "$wm CTRL, L, resizeactive, 40 0"
      ];

      bindm = [
        "$wm, mouse:272, movewindow"
        "$wm, mouse:273, resizewindow"
      ];

      # 音量と輝度は swayosd 経由で叩いて、変更のたびに OSD を出す。
      bindel = [
        ", XF86AudioRaiseVolume, exec, ${osd} --output-volume raise"
        ", XF86AudioLowerVolume, exec, ${osd} --output-volume lower"
        ", XF86MonBrightnessUp, exec, ${osd} --brightness raise"
        ", XF86MonBrightnessDown, exec, ${osd} --brightness lower"
      ];

      bindl = [
        # 蓋を閉じている間は内蔵パネルを外す。外部ディスプレイが無いときは
        # 触らないので、単体で閉じても真っ暗にはならない。
        ", switch:on:Lid Switch, exec, ${lib.getExe lidMonitor} closed"
        ", switch:off:Lid Switch, exec, ${lib.getExe lidMonitor} opened"
        ", XF86AudioMute, exec, ${osd} --output-volume mute-toggle"
        ", XF86AudioMicMute, exec, ${osd} --input-volume mute-toggle"
        ", XF86AudioPlay, exec, ${lib.getExe pkgs.playerctl} play-pause"
        ", XF86AudioNext, exec, ${lib.getExe pkgs.playerctl} next"
        ", XF86AudioPrev, exec, ${lib.getExe pkgs.playerctl} previous"
        ", Caps_Lock, exec, ${osd} --caps-lock"
      ];
    };
  };

  home.packages = [
    pkgs.hyprpicker
    pkgs.hyprshot
    pkgs.nautilus
    pkgs.playerctl
  ];
}
