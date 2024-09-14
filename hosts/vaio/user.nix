{
  config,
  lib,
  inputs,
  ...
}:

{
  home.stateVersion = "24.05";
  imports = [
    ../../home-manager/cli
    ../../home-manager/desktop
    ../../home-manager/gui
  ];
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "eDP-1, 3840x2160@60, 0x0, 1.5"
    ];
    input = {
      kb_layout = "us";
      sensitivity = -0.2;
    };
  };
  programs.waybar.settings = [{
    battery = {
      bat = "BAT1";
      full-at = 100;
    };
  }];
}
