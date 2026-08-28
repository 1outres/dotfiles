{ pkgs, ... }:

# Hyprland setup for the test box, kept apart from the client desktops.
{
  imports = [
    ./home.nix
    ../../modules/home/gcr-ssh-agent.nix
    ../../modules/home/ghostty-linux.nix
    ../../modules/home/gnome-unattended.nix
    ../../modules/home/paseo.nix
    ../../modules/home/playwright-mcp-hermes.nix
    ./home-nix/hyprland.nix
    ./home-nix/hyprlock.nix
    ./home-nix/mako.nix
    ./home-nix/waybar.nix
    ./home-nix/wofi.nix
  ];

  # Only the CLI, not modules/home/onepassword.nix: the SSH agent and
  # op-ssh-sign it wires up both live in the desktop app, which this host does
  # not run. `op account add` plus `op signin` covers what is needed here.
  home.packages = [ pkgs._1password-cli ];
}
