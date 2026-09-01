{ pkgs, ... }:

{
  imports = [
    ./home.nix
    ../../modules/home/claude-desktop.nix
    ../../modules/home/discord.nix
    ../../modules/home/element.nix
    ../../modules/home/fcitx5.nix
    ../../modules/home/ghostty-linux.nix
    ../../modules/home/gnome-catppuccin.nix
    ../../modules/home/gnome-extensions.nix
    ../../modules/home/gnome-key-repeat.nix
    ../../modules/home/gnome-keyboard.nix
    ../../modules/home/gnome-kimpanel.nix
    ../../modules/home/gnome-power.nix
    ../../modules/home/gnome-screenshot.nix
    ../../modules/home/gnome-trusted-wifi.nix
    ../../modules/home/gnome-window-switching.nix
    ../../modules/home/hyprland.nix
    ../../modules/home/mattermost.nix
    ../../modules/home/onepassword.nix
    ../../modules/home/parsec.nix
    ../../modules/home/paseo.nix
    ../../modules/home/t3code.nix
    ../../modules/home/vicinae.nix
    ../../modules/home/xdg-mime-apps.nix
    ../../modules/home/zen-browser.nix
  ];

  # nautilus and a Bluetooth manager already ship with GNOME, so only the tools
  # it does not cover are listed here.
  home.packages = [
    pkgs.fastfetch
    pkgs.gnome-tweaks
    pkgs.google-chrome
    # grim and slurp talk wlr-screencopy, which Mutter does not implement, so
    # these only work in the Hyprland session, not in GNOME.
    pkgs.grim
    pkgs.onlyoffice-desktopeditors
    pkgs.protonmail-desktop
    pkgs.remmina
    pkgs.screen
    pkgs.slack
    pkgs.slurp
    pkgs.wl-clipboard-rs
    pkgs.zoom-us
  ];
}
