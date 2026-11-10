{
  config,
  lib,
  pkgs,
  ...
}:

let
  sessions = config.services.displayManager.sessionData.desktops;
in
{
  imports = [
    ../../../modules/os/nixos/fonts.nix
  ];

  programs.hyprland.enable = true;

  # Start the session from the files that the Hyprland module registers, so
  # this keeps working when Hyprland changes how it should be launched.
  services.greetd = {
    enable = true;
    settings.default_session.command = lib.concatStringsSep " " [
      (lib.getExe pkgs.tuigreet)
      "--time"
      "--remember"
      "--remember-session"
      "--sessions ${sessions}/share/wayland-sessions"
    ];
  };

  # Hyprland writes its stock config on first start. That config opens these
  # with the terminal and app launcher keys.
  environment.systemPackages = [
    pkgs.kitty
    pkgs.hyprlauncher
  ];
}
