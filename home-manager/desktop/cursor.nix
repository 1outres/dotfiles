{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    capitaine-cursors
  ];
  home.file.".icons/default".source = "${pkgs.capitaine-cursors}/share/icons/capitaine-cursors";
}
