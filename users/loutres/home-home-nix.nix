{ pkgs, ... }:

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

  # Only the CLI, not modules/home/onepassword.nix: the SSH agent and
  # op-ssh-sign it wires up both live in the desktop app, which this host does
  # not run. `op account add` plus `op signin` covers what is needed here.
  home.packages = [ pkgs._1password-cli ];
}
