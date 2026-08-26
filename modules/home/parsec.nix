{ pkgs, ... }:

let
  # nixpkgs downloads this .deb from a web.archive.org snapshot, and Wayback now
  # answers that URL with HTTP 503, so the build cannot even start. Take the same
  # package from the vendor instead. That URL always serves the newest release,
  # so the hash below has to change whenever Parsec ships a new build.
  parsec = pkgs.parsec-bin.overrideAttrs {
    version = "150-104a";
    src = pkgs.fetchurl {
      url = "https://builds.parsec.app/package/parsec-linux.deb";
      hash = "sha256-yKRAdxPXLcscWfCCl36B4bno/9Z50GZogs3kyKCCHdI=";
    };
  };

  coreutils = pkgs.coreutils;
  xdotool = "${pkgs.xdotool}/bin/xdotool";

  # Parsec leaves WM_CLASS empty on its X11 window, so GNOME can match the
  # window to no application at all and the dock shows a generic icon. Naming
  # the window after parsecd.desktop is enough, and Mutter re-reads the property
  # when it changes. It can only be set once the window exists, so the wrapper
  # waits for it. `exec` keeps the PID, which is what xdotool searches by.
  wrapper = pkgs.writeShellScriptBin "parsecd" ''
    (
      for _ in $(${coreutils}/bin/seq 1 60); do
        windows=$(${xdotool} search --pid "$$" 2>/dev/null || true)
        if [ -n "$windows" ]; then
          for window in $windows; do
            ${xdotool} set_window --class parsecd --classname parsecd "$window"
          done
          break
        fi
        ${coreutils}/bin/sleep 0.5
      done
    ) &

    exec ${parsec}/bin/parsecd "$@"
  '';
in
{
  home.packages = [
    (pkgs.symlinkJoin {
      name = "parsec-bin-${parsec.version}";
      paths = [ parsec ];
      postBuild = ''
        rm $out/bin/parsecd
        cp ${wrapper}/bin/parsecd $out/bin/parsecd
      '';
    })
  ];
}
