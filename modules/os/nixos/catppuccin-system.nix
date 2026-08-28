{ lib, pkgs, ... }:

# The parts of the machine that sit outside a user session: the text consoles
# and the login screen. Everything a user session draws is handled by
# modules/home/catppuccin-theme.nix instead.
#
# The boot itself is left alone on purpose. A splash screen hides the service
# log, which is worth more than a themed few seconds.

let
  palette = import ../../catppuccin/palette.nix;
  themes = import ../../catppuccin/packages.nix { inherit pkgs; };

  hex = lib.removePrefix "#";
in
{
  # The 16 console colours, in the order the kernel expects. Catppuccin gives
  # the bright half the same hues as the normal half, so the two blocks repeat.
  console.colors = map hex [
    palette.surface1
    palette.red
    palette.green
    palette.yellow
    palette.blue
    palette.pink
    palette.teal
    palette.subtext1
    palette.surface2
    palette.red
    palette.green
    palette.yellow
    palette.blue
    palette.pink
    palette.teal
    palette.subtext0
  ];

  # GDM runs as its own user, so the greeter can only be reached through this
  # database. mkBefore puts it ahead of the greeter defaults that
  # services.displayManager.gdm appends. The background behind the greeter is
  # baked into gnome-shell's gresource and cannot be replaced from here.
  programs.dconf.profiles.gdm.databases = lib.mkBefore [
    {
      settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        accent-color = "purple";
        cursor-theme = themes.cursors.name;
        icon-theme = themes.icons.name;
        font-name = "Noto Sans CJK JP 11";
      };
    }
  ];

  # The greeter does not read the user's profile, so its cursor and icons have
  # to exist system-wide.
  environment.systemPackages = [
    themes.cursors.package
    themes.icons.package
  ];
}
