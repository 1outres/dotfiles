{ inputs, ... }:

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
}
