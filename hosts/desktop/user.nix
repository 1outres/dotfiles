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
      "DP-3, 3840x2160@160, 0x0, 1"
    ];
    input = {
      kb_layout = "us";
      sensitivity = -1.0;
    };
  };
}
