{ ... }:

# GNOME Shell's screenshot UI is the only thing that can select an area on this
# desktop. grim and slurp speak wlr-screencopy, which Mutter does not implement,
# and gnome-screenshot lost its own area mode when the shell took the D-Bus
# interface private.

{
  imports = [ ./dconf-reload.nix ];

  dconf.settings."org/gnome/shell/keybindings" = {
    show-screenshot-ui = [
      "Print"
      "<Super><Shift>4"
    ];
  };
}
