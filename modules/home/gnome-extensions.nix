{ pkgs, ... }:

{
  imports = [ ./dconf-reload.nix ];

  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.appindicator; }
      { package = pkgs.gnomeExtensions.caffeine; }
      { package = pkgs.gnomeExtensions.dash-to-dock; }
    ];
  };
}
