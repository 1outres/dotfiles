{ ... }:

# Hyprland setup for the test box, kept apart from the client desktops.
{
  imports = [
    ./home.nix
    ../../modules/home/gcr-ssh-agent.nix
    ../../modules/home/ghostty-linux.nix
    ../../modules/home/gnome-unattended.nix
    ../../modules/home/hyprland.nix
    ../../modules/home/hyprlock.nix
    ../../modules/home/mako.nix
    ../../modules/home/paseo.nix
    ../../modules/home/playwright-mcp-hermes.nix
    ../../modules/home/waybar.nix
    ../../modules/home/wofi.nix
  ];
}
