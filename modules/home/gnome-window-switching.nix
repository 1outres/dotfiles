{ ... }:

# Super+` walks the windows of the focused app, the way Cmd+` does on macOS.
#
# switch-group, which GNOME binds here by default, cannot feel the same: it
# holds the key for 150 ms before it draws its popup and only moves the focus
# once the modifier comes back up, so a quick press does nothing at all. Both
# numbers live in gnome-shell and no setting reaches them.
#
# cycle-group moves the focus on the key press itself, so it takes Super and
# switch-group keeps the Alt spelling for when the full list is wanted. Leaving
# Super on both would give one key two actions.

{
  imports = [ ./dconf-reload.nix ];

  dconf.settings."org/gnome/desktop/wm/keybindings" = {
    cycle-group = [ "<Super>Above_Tab" ];
    cycle-group-backward = [ "<Shift><Super>Above_Tab" ];

    switch-group = [ "<Alt>Above_Tab" ];
    switch-group-backward = [ "<Shift><Alt>Above_Tab" ];
  };
}
