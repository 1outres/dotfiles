{
  config,
  lib,
  pkgs,
  username,
  ...
}:

# Machine defaults for the Rikka session, set so it behaves like chena. Rikka
# reads $XDG_CONFIG_DIRS/rikka/<domain>.toml under the user's own
# ~/.config/rikka/<domain>.toml, so anything changed in Settings still wins.

let
  chena = config.home-manager.users.${username}.chena;

  toml = pkgs.formats.toml { };

  # Rikka names a wallpaper by its file name in ~/Pictures/Wallpaper.
  wallpaper = "chena.png";

  # Rikka binds one chord per action, so a workspace gets only chena's letter
  # key and not its number key as well. Workspaces past chena's keys are left
  # unbound, as they are in chena.
  workspaceChord =
    modifiers: index:
    lib.optionalString (index <= lib.length chena.workspaces.keys)
      "${modifiers}+${lib.elemAt chena.workspaces.keys (index - 1)}";

  workspaceBindings = lib.listToAttrs (
    lib.concatMap (index: [
      (lib.nameValuePair "workspace-${toString index}" (workspaceChord "Alt" index))
      (lib.nameValuePair "move-to-workspace-${toString index}" (workspaceChord "Alt+Shift" index))
    ]) (lib.range 1 10)
  );

  settings = {
    # Rikka locks a session it starts on the console, because its installer
    # logs in without a password. Here the greeter has already asked for one.
    "rikka.lock" = {
      at-login = false;
      idle = 5;
    };

    "rikka.power" = {
      screen-off-plugged = 6;
      screen-off-battery = 6;
      # On external power the machine is kept running for builds and SSH
      # sessions (hosts/nixos/x13g2/power.nix), and chena never sleeps on idle.
      suspend-plugged = 0;
      suspend-battery = 0;
    };

    "rikka.appearance" = {
      inherit wallpaper;
    };

    "rikka.ime" = {
      keyboard-options = lib.concatStringsSep "," chena.keyboard.options;
    };

    "rikka.pointer" = {
      mouse-natural-scroll = true;
      touchpad-natural-scroll = chena.touchpad.naturalScroll;
      # The schema takes a float, and chena's default is the integer 1.
      touchpad-scroll-factor = chena.touchpad.scrollFactor * 1.0;
      touchpad-click-method = if chena.touchpad.clickFinger then "fingers" else "areas";
    };

    # chena starts apps with SUPER and moves windows with ALT.
    "rikka.input" = workspaceBindings // {
      toggle-launcher = "Super+Space";
      clipboard-history = "Alt+Space";
      toggle-floating = "Alt+T";

      focus-column-left = "Alt+H";
      focus-window-down = "Alt+J";
      focus-window-up = "Alt+K";
      focus-column-right = "Alt+L";

      move-column-left = "Alt+Shift+H";
      move-window-down = "Alt+Shift+J";
      move-window-up = "Alt+Shift+K";
      move-column-right = "Alt+Shift+L";
    };
  };
in
{
  environment.etc = lib.mapAttrs' (
    domain: values:
    lib.nameValuePair "xdg/rikka/${domain}.toml" {
      source = toml.generate "${domain}.toml" values;
    }
  ) settings;

  home-manager.users.${username}.home.file."Pictures/Wallpaper/${wallpaper}".source = chena.wallpaper;
}
