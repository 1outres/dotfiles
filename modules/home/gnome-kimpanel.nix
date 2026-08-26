{ pkgs, ... }:

# fcitx5 asks for this extension on a GNOME Wayland session: without it the
# candidate popup cannot be drawn over GNOME Shell's own surfaces, such as the
# Activities search box.
# https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland#GNOME

{
  imports = [ ./dconf-reload.nix ];

  programs.gnome-shell = {
    enable = true;
    extensions = [ { package = pkgs.gnomeExtensions.kimpanel; } ];
  };
}
