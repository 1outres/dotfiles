{ lib, pkgs, ... }:

let
  # The Lua files read the commands they run from this module, so every
  # command comes from the Nix store instead of whatever is on PATH.
  programs = {
    terminal = lib.getExe pkgs.kitty;
    menu = lib.getExe pkgs.hyprlauncher;
    shutdown = lib.getExe pkgs.hyprshutdown;
    wpctl = lib.getExe' pkgs.wireplumber "wpctl";
    brightnessctl = lib.getExe pkgs.brightnessctl;
    playerctl = lib.getExe pkgs.playerctl;
  };
in
{
  wayland.windowManager.hyprland = {
    enable = true;

    # The NixOS programs.hyprland module installs the compositor and the
    # portal. Setting them here too would add a second build of each.
    package = null;
    portalPackage = null;

    # The default follows home.stateVersion and is "hyprlang" before 26.05.
    configType = "lua";

    extraLuaFiles = {
      programs = {
        content = "return ${lib.generators.toLua { } programs}\n";
        autoLoad = false;
      };
      monitors = ./hyprland-lua/monitors.lua;
      environment = ./hyprland-lua/environment.lua;
      appearance = ./hyprland-lua/appearance.lua;
      layouts = ./hyprland-lua/layouts.lua;
      misc = ./hyprland-lua/misc.lua;
      input = ./hyprland-lua/input.lua;
      binds = ./hyprland-lua/binds.lua;
      rules = ./hyprland-lua/rules.lua;
    };
  };
}
