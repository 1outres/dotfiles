{ ... }:

let
  palette = import ./dracula-palette.nix;
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 32;
      spacing = 8;

      modules-left = [
        "hyprland/workspaces"
        "hyprland/submap"
      ];
      modules-center = [ "hyprland/window" ];
      modules-right = [
        "pulseaudio"
        "cpu"
        "memory"
        "network"
        "clock"
        "tray"
      ];

      "hyprland/workspaces" = {
        format = "{id}";
        on-click = "activate";
      };

      "hyprland/window" = {
        max-length = 80;
        separate-outputs = true;
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟";
        format-icons.default = [
          "󰕿"
          "󰖀"
          "󰕾"
        ];
      };

      cpu.format = "󰻠 {usage}%";

      memory.format = "󰍛 {percentage}%";

      network = {
        format-ethernet = "󰈀 {ipaddr}";
        format-wifi = "󰖩 {essid}";
        format-disconnected = "󰖪";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
      };

      clock = {
        format = "󰥔 {:%Y-%m-%d %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
      };

      tray.spacing = 8;
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Noto Sans CJK JP", sans-serif;
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: ${palette.background};
        color: ${palette.foreground};
      }

      #workspaces button {
        padding: 0 10px;
        color: ${palette.comment};
        background: transparent;
      }

      #workspaces button.active {
        color: ${palette.background};
        background: ${palette.purple};
      }

      #workspaces button.urgent {
        color: ${palette.background};
        background: ${palette.red};
      }

      #window {
        color: ${palette.foreground};
      }

      #clock,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #tray {
        padding: 0 10px;
      }

      #cpu {
        color: ${palette.green};
      }

      #memory {
        color: ${palette.orange};
      }

      #network {
        color: ${palette.cyan};
      }

      #pulseaudio {
        color: ${palette.pink};
      }

      #pulseaudio.muted {
        color: ${palette.comment};
      }

      #clock {
        color: ${palette.yellow};
      }
    '';
  };
}
