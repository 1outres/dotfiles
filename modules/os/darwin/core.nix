{ pkgs, username, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.${username}.home = "/Users/${username}";

  programs.zsh.enable = true;

  services.tailscale.enable = true;

  environment.systemPackages = [
    pkgs.git
  ];

  system.primaryUser = username;
  system.stateVersion = 6;
}
