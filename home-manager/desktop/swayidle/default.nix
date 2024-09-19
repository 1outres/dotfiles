{ pkgs, ... }:
{
  home.packages = with pkgs; [
    swayidle
  ];

  home.file.".bin/sleep.sh".source = ./sleep.sh;
}
