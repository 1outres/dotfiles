{ inputs, pkgs, vars, lib, ... }:
{
  home.packages = with pkgs; [
    brightnessctl
  ];

  programs.waybar = {
    enable = true;
    style = ./style.css;
    settings = [{
      height = 30;
      layer = "top";
      position = "top";
      mod = "dock";
      exclusive = true;
      passthrough = false;
      gtk-layer-shell = true;
      modules-left = [
        "hyprland/workspaces"
      ];
      modules-center = [
        "custom/clock"
      ];
      modules-right = [
        "network"
        "battery"
        "custom/brightness"
        "pulseaudio"
        "pulseaudio#microphone"
        "tray"
      ];

      battery = {
        bat = vars.battery or "BAT1";
      };

      tray = {
        icon-size = 15;
        spacing = 10;
      };

      "custom/clock" = {
        format = "{}";
        exec = "LANG=C date +\"%a %b %d %-I:%M %p\"";
        interval = 1;
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        tooltip = false;
        format-muted =  " Muted";
        on-click = "pamixer -t";
        on-scroll-up = "pamixer -i 5";
        on-scroll-down = "pamixer -d 5";
        scroll-step = 5;
        format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
        };
      };

      "pulseaudio#microphone" = {
        format = "{format_source}";
        format-source = "Mic: {volume}%";
        format-source-muted = "Mic: Muted";
        on-click = "pamixer --default-source -t";
        on-scroll-up = "pamixer --default-source -i 5";
        on-scroll-down = "pamixer --default-source -d 5";
        scroll-step = 5;
      };

      network = {
        format-wifi = " ";
        format-ethernet = "{ifname} {ipaddr}/{cidr} ";
        format-linked = "{ifname} (No IP) ";
        format-disconnected = "Disconnected ⚠";
      };

      "custom/brightness" = {
        format = "{icon} {}%";
        format-icons = ["" ""];
        exec = "brightnessctl info | grep -Eo '[0-9]{1,3}%'";
        on-scroll-up = "brightnessctl set +5%";
        on-scroll-down = "brightnessctl set 5%-";
        interval = 1;
        tooltip = false;
      };

    }];
  };

  #home.file.".config/waybar/config.jsonc".source = ./config.jsonc;
  #home.file.".config/waybar/style.css".source = ./style.css;
}
