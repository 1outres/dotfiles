{ pkgs, ... }:

{
  home.packages = [
    pkgs.docker-client
    pkgs.docker-compose
    pkgs.incus
    pkgs.opentofu
    pkgs.zsh
  ];
}
