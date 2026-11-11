{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.chena.style) colors;

  fcitx5Remote = lib.getExe' pkgs.fcitx5 "fcitx5-remote";
in
{
  imports = [
    ./home.nix
    inputs.chena.homeModules.default
    ../../modules/home/fcitx5.nix
    # chena themes Ghostty, so this takes only the behavior settings and not
    # the Linux font override in ghostty-linux.nix.
    ../../modules/home/ghostty.nix
    ../../modules/home/google-chrome.nix
    ../../modules/home/onepassword.nix
    ../../modules/home/onepassword-autostart.nix
  ];

  chena = {
    enable = true;
    keyboard.options = [ "ctrl:nocaps" ];
    touchpad.scrollFactor = 0.5;
    wallpaper = ../../bg.png;

    # The roBa firmware already flips its scroll, which suits macOS with
    # natural scrolling on. Flipping it again here makes it scroll like a
    # normal mouse.
    devices."zmk-project-roba-mouse".naturalScroll = true;

    # Tapping Cmd works like the Eisu and Kana keys on a Mac keyboard: left
    # turns Japanese input off and right turns it on.
    extraLua.input-method = ''
      hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("${fcitx5Remote} -c"), { release = true })
      hl.bind("SUPER + SUPER_R", hl.dsp.exec_cmd("${fcitx5Remote} -o"), { release = true })
    '';

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

  tmuxWheel.lines = 2;

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
