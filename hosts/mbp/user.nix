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
      "eDP-1, 3024x1890@60, 0x0, 1"
    ];
    input = {
      kb_layout = "us";
      sensitivity = -0.2;
    };
  };
  programs.waybar.settings = [{
    battery = {
      bat = "macsmc-battery";
      full-at = 99;
    };
  }];
}
