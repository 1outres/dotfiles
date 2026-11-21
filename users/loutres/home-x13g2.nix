{ pkgs, ... }:

{
  imports = [
    ./home.nix
    ../../modules/home/chena.nix
    ../../modules/home/claude-desktop.nix
    ../../modules/home/discord.nix
    ../../modules/home/element.nix
    ../../modules/home/google-chrome.nix
    ../../modules/home/mattermost.nix
    ../../modules/home/onepassword.nix
    ../../modules/home/onepassword-autostart.nix
    ../../modules/home/parsec.nix
    ../../modules/home/paseo.nix
    ../../modules/home/ssh-away-agent.nix
    ../../modules/home/xdg-fonts.nix
    ../../modules/home/xdg-mime-apps.nix
    ../../modules/home/zen-browser.nix
  ];

  chena = {
    shell = "shoji-bar-4";

    monitors = [
      {
        output = "";
        scale = 1;
      }
    ];

    clamshell = {
      switch = "Lid Switch";
      output = "eDP-1";
    };
  };

  home.packages = [
    pkgs.anydesk
    pkgs.fastfetch
    pkgs.grim
    pkgs.onlyoffice-desktopeditors
    pkgs.protonmail-desktop
    pkgs.remmina
    pkgs.screen
    pkgs.slack
    pkgs.slurp
    pkgs.zoom-us
  ];
}
