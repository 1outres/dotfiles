{ config, inputs, ... }:

let
  inherit (config.chena.style) colors;
in
{
  imports = [
    inputs.chena.homeModules.default
    ./fcitx5.nix
    # chena themes Ghostty, so this takes only the behavior settings and not
    # the Linux font override in ghostty-linux.nix.
    ./ghostty.nix
  ];

  chena = {
    enable = true;
    shell = "shoji-bar-4";
    keyboard.options = [ "ctrl:nocaps" ];
    wallpaper = ../../bg.png;
    airpods.enable = true;

    # The roBa firmware already flips its scroll, which suits macOS with
    # natural scrolling on. Flipping it again here makes it scroll like a
    # normal mouse.
    devices."zmk-project-roba-mouse".naturalScroll = true;

    # Keep the vault from showing through blur or in a screen share.
    extraLua.onepassword = ''
      hl.window_rule({
          name  = "float-1password",
          match = { class = "^(1Password)$" },

          float           = true,
          no_blur         = true,
          no_screen_share = true,
      })
    '';
  };

  # Without shell integration Ghostty cannot tell an idle prompt from a running
  # program, so it asks before every close, and its dialog selects Cancel.
  programs.ghostty.settings.confirm-close-surface = false;

  tmuxPower.greys = {
    G01 = colors.desktop;
    G02 = colors.desktop;
    G03 = colors.surface;
    G04 = colors.surface;
    G05 = colors.background;
    G06 = colors.selection;
    G07 = colors.border;
    G08 = colors.border;
    G09 = colors.muted;
    G10 = colors.muted;
    G11 = colors.muted;
    G12 = colors.text;
  };
}
