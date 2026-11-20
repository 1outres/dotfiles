{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

# Rikka as a second session next to chena, picked on the greeter. Rikka
# expects to own the machine, so the parts of its module that would also reach
# the chena session are scoped back to the Rikka session here.

let
  base = inputs.rikka.packages.${pkgs.stdenv.hostPlatform.system}.base;

  mimeapps = "share/applications/mimeapps.list";
  scopedMimeapps = "share/applications/rikka-mimeapps.list";
  secrets = "share/dbus-1/services/org.freedesktop.secrets.service";

  scopingCheck = pkgs.runCommand "rikka-session-scoping-check" { } ''
    path=${config.system.path}
    test ! -e "$path/${mimeapps}"
    test "$(readlink -f "$path/${scopedMimeapps}")" = "$(readlink -f ${base}/${mimeapps})"
    ${lib.optionalString config.services.gnome.gnome-keyring.enable ''
      test "$(readlink -f "$path/${secrets}")" = "$(readlink -f ${pkgs.gnome-keyring}/${secrets})"
    ''}
    touch "$out"
  '';
in
{
  imports = [
    inputs.rikka.nixosModules.default
    ./rikka-settings.nix
  ];

  rikka = {
    enable = true;

    # No rikka.autologin.user: it takes display-manager.service for itself,
    # and the greeter has to stay to offer both sessions.

    # The installer's default picks, without "packages". That app and the
    # system half of Settings edit /etc/nixos/rikka and rebuild /etc/nixos,
    # which is not where this machine's configuration lives.
    apps =
      lib.genAttrs
        [
          "browser"
          "calculator"
          "cut"
          "music"
          "paint"
          "task-manager"
          "viewer"
        ]
        (_: {
          enable = true;
        });
  };

  # Rikka ships its own Secret Service under the same D-Bus name as
  # gnome-keyring. Both files land in the system path, so without a priority
  # either could win, and the chena session could lose the keyring 1Password
  # keeps its device login in.
  environment.systemPackages = lib.mkIf config.services.gnome.gnome-keyring.enable [
    (lib.hiPrio pkgs.gnome-keyring)
  ];

  # Rikka's mimeapps.list makes its own apps the default for images, text,
  # video and the web in every session. As rikka-mimeapps.list it is read
  # only where XDG_CURRENT_DESKTOP is rikka. extraSetup also runs for every
  # per-user profile, which does not hold Rikka, hence the test.
  environment.extraSetup = ''
    if [ "$(readlink -f "$out/${mimeapps}")" = "$(readlink -f ${base}/${mimeapps})" ]; then
      rm "$out/${mimeapps}"
      ln -s ${base}/${mimeapps} "$out/${scopedMimeapps}"
    fi
  '';

  system.checks = [ scopingCheck ];

  # Rikka starts fcitx5 itself, and the Rikka session reaches
  # xdg-desktop-autostart.target, which would start a second one.
  systemd.user.units."app-org.fcitx.Fcitx5@autostart.service".enable = false;
}
