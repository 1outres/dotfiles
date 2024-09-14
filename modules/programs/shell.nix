{ pkgs, ... }:
{
  programs.fish.enable = true;
  users.users.loutres = {
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    pciutils
    glib
  ];
}
