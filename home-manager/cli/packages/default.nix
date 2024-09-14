{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fzf
    ghq
    lazygit
  ];
}
