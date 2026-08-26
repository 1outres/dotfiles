{ pkgs, ... }:

# The built-in keyboard is JIS and the external one is US. GNOME gives every
# keyboard the same layout — Mutter has no per-device input source — so the
# session runs on "us" (modules/home/gnome-keyboard.nix) and the built-in board
# is remapped down here instead. Both boards then type what is printed on them.
#
# The direction is not arbitrary: a US board has no key for JIS's yen and ro, so
# a "jp" session would leave the external keyboard unable to type backslash,
# underscore and pipe.
#
# No fallback: a new built-in keyboard has to be added to the ids below. Find
# its vendor:product in /proc/bus/input/devices.

let
  # keyd ships a jp layout but leaves yen and ro undefined, and it only resolves
  # includes under /etc/keyd or /usr/share/keyd, so the file is rebuilt here and
  # installed into /etc/keyd.
  jpLayout = pkgs.runCommand "keyd-jp-layout" { } ''
    anchor='shift = layer(jp_shift)'
    if ! ${pkgs.gnugrep}/bin/grep -qxF "$anchor" ${pkgs.keyd}/share/keyd/layouts/jp; then
      echo "keyd's jp layout no longer ends [jp:layout] with $anchor" >&2
      exit 1
    fi

    ${pkgs.gnused}/bin/sed \
      -e "/^$anchor\$/i yen = backslash\nro = backslash" \
      ${pkgs.keyd}/share/keyd/layouts/jp > $out

    printf 'yen = |\nro = _\n' >> $out
  '';
in
{
  # A real file, not the usual symlink: keyd resolves an include with realpath
  # and refuses anything that leaves its config directory, which every /etc
  # symlink does on NixOS by pointing into /nix/store.
  environment.etc."keyd/jp-layout" = {
    source = jpLayout;
    mode = "0444";
  };

  services.keyd = {
    enable = true;

    keyboards.internal = {
      ids = [ "0001:0001" ];
      extraConfig = ''
        include jp-layout

        [global]
        default_layout = jp
      '';
    };
  };

  # The module only restarts keyd when the .conf changes, and the layout lives
  # in a file of its own, so a layout edit would otherwise sit unused until the
  # next reboot.
  systemd.services.keyd.restartTriggers = [ jpLayout ];
}
