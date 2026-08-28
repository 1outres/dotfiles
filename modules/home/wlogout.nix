{
  config,
  lib,
  pkgs,
  ...
}:

let
  palette = import ../catppuccin/palette.nix;

  lock = lib.getExe config.programs.hyprlock.package;
  systemctl = lib.getExe' pkgs.systemd "systemctl";
  icons = "${pkgs.wlogout}/share/wlogout/icons";
in
{
  programs.wlogout = {
    enable = true;

    layout = [
      {
        label = "lock";
        action = lock;
        text = "Lock";
        keybind = "l";
      }
      {
        # wlogout only runs inside a Hyprland session, where the compositor
        # itself puts hyprctl on PATH.
        label = "logout";
        action = "hyprctl dispatch exit";
        text = "Log out";
        keybind = "e";
      }
      {
        label = "suspend";
        action = "${systemctl} suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "reboot";
        action = "${systemctl} reboot";
        text = "Reboot";
        keybind = "r";
      }
      {
        label = "shutdown";
        action = "${systemctl} poweroff";
        text = "Shut down";
        keybind = "s";
      }
    ];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Noto Sans CJK JP", sans-serif;
        font-size: 14px;
      }

      window {
        background: alpha(${palette.crust}, 0.85);
      }

      button {
        color: ${palette.text};
        background-color: alpha(${palette.base}, 0.9);
        border: 2px solid alpha(${palette.surface0}, 0.9);
        border-radius: 24px;
        margin: 14px;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 22%;
        transition: all 250ms cubic-bezier(0.23, 1, 0.32, 1);
      }

      button:focus,
      button:hover {
        color: ${palette.text};
        background-color: alpha(${palette.mauve}, 0.18);
        border-color: ${palette.mauve};
        background-size: 26%;
      }

      #lock {
        background-image: image(url("${icons}/lock.png"));
      }

      #logout {
        background-image: image(url("${icons}/logout.png"));
      }

      #suspend {
        background-image: image(url("${icons}/suspend.png"));
      }

      #reboot {
        background-image: image(url("${icons}/reboot.png"));
      }

      #shutdown {
        background-image: image(url("${icons}/shutdown.png"));
      }
    '';
  };
}
