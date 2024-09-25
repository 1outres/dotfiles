{ config, libs, pkgs, inputs, ... }:
{
  imports = 
  [
  ];

  networking = {
    hostName = "loutres-darwin";
  };

  services.nix-daemon.enable = true;

  users.users.loutres.home = "/Users/loutres";

  system.stateVersion = 5;
}
