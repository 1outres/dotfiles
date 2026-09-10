{ lib, pkgs, ... }:

let
  palette = import ../catppuccin/palette.nix;

  osd = lib.getExe' pkgs.swayosd "swayosd-client";
  swayncClient = lib.getExe' pkgs.swaynotificationcenter "swaync-client";
  mixer = lib.getExe pkgs.pavucontrol;
  bluetoothManager = lib.getExe' pkgs.blueman "blueman-manager";
  networkEditor = lib.getExe' pkgs.networkmanagerapplet "nm-connection-editor";
  powerMenu = lib.getExe pkgs.wlogout;

  workspaceCount = builtins.length (import ./assets/workspaces.nix);

  # split-monitor-workspaces numbers workspaces straight through: the first
  # monitor gets 1..9, the second 10..18, and so on. The bar should read 1..9 on
  # every screen, so each range is folded back onto the same nine labels.
  workspaceIcons = builtins.listToAttrs (
    builtins.concatMap (
      monitor:
      builtins.genList (
        index: lib.nameValuePair (toString (monitor * workspaceCount + index + 1)) (toString (index + 1))
      ) workspaceCount
    ) (lib.range 0 3)
  );

  # GTK's CSS has no variables of its own, so the palette is emitted as
  # @define-color and referenced by name below.
  defineColors = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: value: "@define-color ${name} ${value};") palette
  );
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 38;
      spacing = 0;
      margin-top = 8;
      margin-left = 12;
      margin-right = 12;

      modules-left = [
        "hyprland/workspaces"
        "hyprland/submap"
      ];
      modules-center = [ "hyprland/window" ];
      modules-right = [
        "privacy"
        "mpris"
        "tray"
        "backlight"
        "pulseaudio"
        "bluetooth"
        "network"
        "battery"
        "clock"
        "custom/notification"
        "custom/power"
      ];

      "hyprland/workspaces" = {
        format = "{icon}";
        on-click = "activate";
        format-icons = workspaceIcons;
      };

      "hyprland/submap" = {
        format = "󰌌 {}";
        tooltip = false;
      };

      "hyprland/window" = {
        format = "{title}";
        max-length = 70;
        separate-outputs = true;
        icon = true;
        icon-size = 16;
        rewrite = {
          "" = "󰇄  Desktop";
        };
      };

      privacy = {
        icon-spacing = 6;
        icon-size = 13;
        transition-duration = 250;
        modules = [
          {
            type = "screenshare";
            tooltip = true;
          }
          {
            type = "audio-in";
            tooltip = true;
          }
        ];
      };

      mpris = {
        format = "{player_icon} {dynamic}";
        format-paused = "{status_icon} {dynamic}";
        dynamic-len = 34;
        dynamic-order = [
          "title"
          "artist"
        ];
        player-icons = {
          default = "󰎈";
          spotify = "󰓇";
          firefox = "󰈹";
        };
        status-icons.paused = "󰏤";
        tooltip-format = "{player}: {title}\n{artist}";
      };

      tray = {
        icon-size = 16;
        spacing = 10;
      };

      backlight = {
        format = "{icon} {percent}%";
        format-icons = [
          "󰃞"
          "󰃟"
          "󰃠"
        ];
        tooltip-format = "Brightness {percent}%";
        on-scroll-up = "${osd} --brightness raise";
        on-scroll-down = "${osd} --brightness lower";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟";
        format-bluetooth = "󰂯 {volume}%";
        format-bluetooth-muted = "󰂲";
        format-icons = {
          headphone = "󰋋";
          headset = "󰋎";
          default = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
        };
        tooltip-format = "{desc} — {volume}%";
        on-click = mixer;
        on-scroll-up = "${osd} --output-volume raise";
        on-scroll-down = "${osd} --output-volume lower";
      };

      bluetooth = {
        format = "󰂯";
        format-disabled = "󰂲";
        format-off = "󰂲";
        format-connected = "󰂱 {num_connections}";
        tooltip-format = "{controller_alias}";
        tooltip-format-connected = "{device_enumerate}";
        on-click = bluetoothManager;
      };

      network = {
        format-wifi = "󰖩 {signalStrength}%";
        format-ethernet = "󰈀";
        format-linked = "󰈀";
        format-disconnected = "󰖪";
        tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ipaddr}/{cidr}";
        tooltip-format-ethernet = "{ifname}\n{ipaddr}/{cidr}";
        tooltip-format-disconnected = "Disconnected";
        on-click = networkEditor;
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-icons = [
          "󰁺"
          "󰁻"
          "󰁼"
          "󰁽"
          "󰁾"
          "󰁿"
          "󰂀"
          "󰂁"
          "󰂂"
          "󰁹"
        ];
        tooltip-format = "{timeTo}\n{power:.1f} W";
      };

      clock = {
        format = "󰥔 {:%H:%M}";
        format-alt = "󰃭 {:%Y-%m-%d %a}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "month";
          weeks-pos = "right";
          format = {
            months = "<span color='${palette.mauve}'><b>{}</b></span>";
            days = "<span color='${palette.text}'>{}</span>";
            weeks = "<span color='${palette.sapphire}'>W{}</span>";
            weekdays = "<span color='${palette.peach}'><b>{}</b></span>";
            today = "<span color='${palette.pink}'><b><u>{}</u></b></span>";
          };
        };
      };

      "custom/notification" = {
        format = "{icon}";
        format-icons = {
          notification = "󰂚";
          none = "󰂜";
          dnd-notification = "󰂛";
          dnd-none = "󰂛";
          inhibited-notification = "󰂚";
          inhibited-none = "󰂜";
          dnd-inhibited-notification = "󰂛";
          dnd-inhibited-none = "󰂛";
        };
        return-type = "json";
        exec = "${swayncClient} --subscribe --skip-wait";
        on-click = "${swayncClient} --toggle-panel --skip-wait";
        on-click-right = "${swayncClient} --toggle-dnd --skip-wait";
        escape = true;
        tooltip = false;
      };

      "custom/power" = {
        format = "󰐥";
        on-click = powerMenu;
        tooltip = false;
      };
    };

    style = ''
      ${defineColors}

      * {
        font-family: "JetBrainsMono Nerd Font", "Noto Sans CJK JP", sans-serif;
        font-size: 13px;
        font-weight: 500;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      /* The bar itself stays invisible; each group below draws its own island. */
      window#waybar {
        background: transparent;
        color: @text;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background: alpha(@base, 0.72);
        border: 1px solid alpha(@surface1, 0.55);
        border-radius: 16px;
        padding: 0 6px;
      }

      .modules-left {
        padding: 0 4px;
      }

      #workspaces button {
        min-width: 26px;
        margin: 4px 2px;
        padding: 0 4px;
        border-radius: 12px;
        color: @overlay0;
        background: transparent;
        transition:
          min-width 220ms cubic-bezier(0.23, 1, 0.32, 1),
          background 220ms cubic-bezier(0.23, 1, 0.32, 1),
          color 220ms cubic-bezier(0.23, 1, 0.32, 1);
      }

      #workspaces button:hover {
        color: @text;
        background: alpha(@surface1, 0.7);
      }

      /* The focused workspace widens into a pill so it reads at a glance. */
      #workspaces button.active {
        min-width: 44px;
        color: @crust;
        background: linear-gradient(135deg, @mauve, @pink);
      }

      #workspaces button.urgent {
        color: @crust;
        background: @red;
      }

      #submap {
        margin: 0 6px;
        color: @peach;
      }

      #window {
        margin: 0 10px;
        color: @subtext0;
      }

      window#waybar.empty .modules-center {
        background: transparent;
        border-color: transparent;
      }

      #privacy,
      #mpris,
      #tray,
      #backlight,
      #pulseaudio,
      #bluetooth,
      #network,
      #battery,
      #clock,
      #custom-notification,
      #custom-power {
        margin: 4px 2px;
        padding: 0 9px;
        border-radius: 12px;
        background: transparent;
        transition: background 220ms cubic-bezier(0.23, 1, 0.32, 1);
      }

      #backlight:hover,
      #pulseaudio:hover,
      #bluetooth:hover,
      #network:hover,
      #battery:hover,
      #clock:hover,
      #custom-notification:hover,
      #custom-power:hover {
        background: alpha(@surface1, 0.7);
      }

      #privacy {
        color: @red;
      }

      #mpris {
        color: @green;
      }

      #mpris.paused {
        color: @overlay1;
      }

      #backlight {
        color: @yellow;
      }

      #pulseaudio {
        color: @sky;
      }

      #pulseaudio.muted {
        color: @overlay0;
      }

      #bluetooth {
        color: @blue;
      }

      #bluetooth.disabled,
      #bluetooth.off {
        color: @overlay0;
      }

      #network {
        color: @teal;
      }

      #network.disconnected {
        color: @red;
      }

      #battery {
        color: @green;
      }

      #battery.charging,
      #battery.plugged {
        color: @teal;
      }

      #battery.warning:not(.charging) {
        color: @peach;
      }

      #battery.critical:not(.charging) {
        color: @red;
      }

      #clock {
        color: @mauve;
        font-weight: 600;
      }

      #custom-notification {
        color: @pink;
      }

      #custom-power {
        color: @red;
      }

      tooltip {
        background: alpha(@mantle, 0.96);
        border: 1px solid @surface1;
        border-radius: 12px;
      }

      tooltip label {
        color: @text;
        padding: 2px;
      }
    '';
  };

  home.packages = [
    pkgs.blueman
    pkgs.networkmanagerapplet
    pkgs.pavucontrol
  ];
}
