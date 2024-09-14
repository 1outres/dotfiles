{ inputs, pkgs, ... }:
{
  imports = [
    ./settings.nix
    ./key-binds.nix
  ];
  home.packages = with pkgs; [
    wofi
    swaybg
  ];
  home.file.".config/hypr/bg.png".source = ./bg.png;
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    systemd.enable = true;
    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.system}.default
    ];
  };
}
