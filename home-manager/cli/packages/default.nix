{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fzf ghq lazygit go
    ffmpeg htop 
    unzip zip
    grim slurp python3
    screen xclip neofetch tty-clock cava
    jq yq-go
    kubectl
  ];
}
