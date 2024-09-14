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
