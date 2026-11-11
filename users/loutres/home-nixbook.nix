{ config, inputs, ... }:

{
  imports = [
    ./home.nix
    inputs.chena.homeModules.default
    ../../modules/home/ghostty-linux.nix
    ../../modules/home/google-chrome.nix
  ];

  chena = {
    enable = true;
    terminal = config.programs.ghostty.package;
    keyboard.options = [ "ctrl:nocaps" ];
  };
}
