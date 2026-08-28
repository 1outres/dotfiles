{ lib, ... }:

let
  palette = import ../catppuccin/palette.nix;

  defineColors = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: value: "@define-color ${name} ${value};") palette
  );
in
{
  services.swaync = {
    enable = true;

    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "user";

      control-center-margin-top = 10;
      control-center-margin-bottom = 10;
      control-center-margin-right = 12;
      control-center-margin-left = 10;
      control-center-width = 440;
      control-center-height = 640;

      notification-window-width = 420;
      notification-icon-size = 48;
      notification-body-image-height = 120;
      notification-body-image-width = 220;

      timeout = 6;
      timeout-low = 4;
      timeout-critical = 0;

      fit-to-screen = false;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = true;
      hide-on-action = true;

      widgets = [
        "title"
        "dnd"
        "mpris"
        "volume"
        "notifications"
      ];

      widget-config = {
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "󰎟  Clear all";
        };
        dnd.text = "Do not disturb";
        mpris = {
          image-size = 92;
          image-radius = 12;
        };
        volume = {
          label = "󰕾";
          show-per-app = true;
        };
      };
    };

    style = ''
      ${defineColors}

      * {
        font-family: "JetBrainsMono Nerd Font", "Noto Sans CJK JP", sans-serif;
        font-size: 13px;
      }

      /* Hyprland blurs these layers (see modules/home/hyprland.nix), so the
         panels can stay translucent without turning into mush. */
      .control-center,
      .floating-notifications.background .notification-row .notification-background {
        background: alpha(@base, 0.82);
        border: 1px solid alpha(@surface1, 0.6);
        border-radius: 18px;
      }

      .blank-window {
        background: transparent;
      }

      .control-center {
        padding: 12px;
      }

      .widget-title {
        color: @text;
        font-size: 16px;
        font-weight: 600;
        margin: 6px 4px 12px 4px;
      }

      .widget-title > button {
        color: @subtext0;
        background: alpha(@surface0, 0.9);
        border: none;
        border-radius: 12px;
        padding: 4px 12px;
        transition: all 200ms cubic-bezier(0.23, 1, 0.32, 1);
      }

      .widget-title > button:hover {
        color: @crust;
        background: @red;
      }

      .widget-dnd {
        color: @text;
        margin: 4px 4px 12px 4px;
      }

      .widget-dnd > switch {
        background: @surface0;
        border: none;
        border-radius: 999px;
      }

      .widget-dnd > switch:checked {
        background: @mauve;
      }

      .widget-dnd > switch slider {
        background: @overlay2;
        border-radius: 999px;
      }

      .widget-dnd > switch:checked slider {
        background: @crust;
      }

      .widget-mpris {
        background: alpha(@mantle, 0.8);
        border-radius: 14px;
        padding: 8px;
        margin: 0 4px 12px 4px;
      }

      .widget-mpris-title {
        color: @text;
        font-weight: 600;
      }

      .widget-mpris-subtitle {
        color: @subtext0;
      }

      .widget-volume {
        background: alpha(@mantle, 0.8);
        border-radius: 14px;
        padding: 8px 12px;
        margin: 0 4px 12px 4px;
        color: @sky;
      }

      .widget-volume trough {
        background: @surface0;
        border-radius: 999px;
        min-height: 6px;
      }

      .widget-volume highlight {
        background: @sky;
        border-radius: 999px;
        min-height: 6px;
      }

      .notification-row {
        outline: none;
        margin: 0 4px 8px 4px;
      }

      .notification-row .notification-background {
        background: alpha(@mantle, 0.92);
        border: 1px solid alpha(@surface1, 0.6);
        border-radius: 14px;
        padding: 0;
      }

      .notification-row .notification-background .notification {
        padding: 4px;
      }

      .notification-row .notification-background .notification .notification-action,
      .notification-row .notification-background .notification .notification-default-action {
        background: transparent;
        border: none;
        border-radius: 12px;
        padding: 8px;
        transition: background 200ms cubic-bezier(0.23, 1, 0.32, 1);
      }

      .notification-row .notification-background .notification .notification-default-action:hover {
        background: alpha(@surface0, 0.9);
      }

      .summary {
        color: @text;
        font-size: 14px;
        font-weight: 600;
      }

      .time {
        color: @overlay1;
        font-size: 12px;
      }

      .body {
        color: @subtext0;
      }

      .close-button {
        color: @subtext0;
        background: alpha(@surface0, 0.9);
        border: none;
        border-radius: 999px;
        margin: 6px;
        padding: 2px;
        transition: all 200ms cubic-bezier(0.23, 1, 0.32, 1);
      }

      .close-button:hover {
        color: @crust;
        background: @red;
      }

      .notification-row .notification-background .notification.critical {
        border-color: @red;
      }

      .notification-group-headers {
        color: @subtext0;
        font-weight: 600;
      }

      .notification-group-icon {
        color: @mauve;
      }
    '';
  };
}
