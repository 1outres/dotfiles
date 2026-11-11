{ config, inputs, ... }:

let
  inherit (config.chena.style) colors;
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
  ];

  chena = {
    enable = true;
    keyboard.options = [ "ctrl:nocaps" ];
  };

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
