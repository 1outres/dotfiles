{
  config,
  lib,
  pkgs,
  ...
}:

let
  toLuaModule = value: "return ${lib.generators.toLua { } value}\n";

  # The Lua files read the commands they run from this module, so every
  # command comes from the Nix store instead of whatever is on PATH.
  programs = {
    terminal = lib.getExe config.programs.ghostty.package;
    menu = lib.getExe pkgs.hyprlauncher;
    shutdown = lib.getExe pkgs.hyprshutdown;
    wpctl = lib.getExe' pkgs.wireplumber "wpctl";
    brightnessctl = lib.getExe pkgs.brightnessctl;
    playerctl = lib.getExe pkgs.playerctl;
  };

  cursor = {
    inherit (config.home.pointerCursor) name size;
  };
in
{
  imports = [ ./ghostty-linux.nix ];

  # Without a cursor theme Hyprland draws its own built-in fallback cursor.
  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

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
        content = toLuaModule programs;
        autoLoad = false;
      };
      cursor = {
        content = toLuaModule cursor;
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
