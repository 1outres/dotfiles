{
  config,
  lib,
  pkgs,
  ...
}:

let
  lock = lib.getExe config.programs.hyprlock.package;
  pidof = lib.getExe' pkgs.procps "pidof";
  loginctl = lib.getExe' pkgs.systemd "loginctl";
  brightnessctl = lib.getExe pkgs.brightnessctl;

  # hypridle only ever runs inside a Hyprland session, where the compositor
  # itself puts hyprctl on PATH. Pinning pkgs.hyprland here instead would pull
  # in a second build of the compositor for one helper binary.
  hyprctl = "hyprctl";
in
{
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "${pidof} hyprlock || ${lock}";
        before_sleep_cmd = "${loginctl} lock-session";
        after_sleep_cmd = "${hyprctl} dispatch dpms on";
      };

      # GNOME 側 (modules/home/gnome-power.nix) と同じ間隔に揃える。60 秒で
      # ロックし、放置してもサスペンドはしない。蓋を閉じたときだけ寝る。
      listener = [
        {
          timeout = 45;
          on-timeout = "${brightnessctl} --save set 10%";
          on-resume = "${brightnessctl} --restore";
        }
        {
          timeout = 60;
          on-timeout = "${loginctl} lock-session";
        }
        {
          timeout = 90;
          on-timeout = "${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on";
        }
      ];
    };
  };
}
