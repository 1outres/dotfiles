{ lib, pkgs, ... }:

let
  fontPackages = [
    pkgs.monaspace
  ]
  ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  fontsEnv = pkgs.buildEnv {
    name = "darwin-fonts";
    paths = fontPackages;
    pathsToLink = [ "/share/fonts" ];
    ignoreCollisions = true;
  };
in
{
  # macOS CoreText / Font Book can ignore symlinks into /nix/store, so copy the
  # dereferenced font files into ~/Library/Fonts/Nix whenever the derivation
  # changes.
  home.activation.darwinFonts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    fontsDir="$HOME/Library/Fonts/Nix"
    stampFile="$fontsDir/.nix-store-path"

    if [[ ! -f "$stampFile" ]] || [[ "$(cat "$stampFile")" != "${fontsEnv}" ]]; then
      run mkdir -p "$fontsDir"
      run ${pkgs.rsync}/bin/rsync \
        --archive \
        --copy-links \
        --delete \
        --chmod=Du+w,Fu+w \
        --exclude='.nix-store-path' \
        "${fontsEnv}/share/fonts/" "$fontsDir/"
      if [[ -z "''${DRY_RUN:-}" ]]; then
        printf '%s\n' "${fontsEnv}" > "$stampFile"
      fi
    fi
  '';
}
