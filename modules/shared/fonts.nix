{
  inputs,
  lib,
  pkgs,
  system,
  ...
}:

# The Japanese font set every host shares. Latin and icon fonts stay in the
# per-OS modules that import this one.

let
  # Branch on the system string rather than on pkgs: reading pkgs to decide
  # which attributes this module defines makes the module system recurse.
  isDarwin = lib.hasSuffix "-darwin" system;

  # Fonts that ship with an operating system are licensed with it and cannot be
  # redistributed, so the files live in the private flake.
  licensedFonts =
    name:
    pkgs.runCommandLocal "${name}-fonts"
      {
        meta = {
          description = "Japanese fonts that ship with ${name}";
          license = lib.licenses.unfree;
          platforms = lib.platforms.all;
        };
      }
      ''
        install -Dm444 -t "$out/share/fonts/truetype" ${inputs.private.fonts.${name}}/*.ttc
      '';
in
{
  fonts.packages =
    (with pkgs; [
      # Noto Sans/Serif CJK JP are the same typefaces as Source Han Sans/Serif,
      # and their variable builds expose every weight from Thin to Black, so a
      # separate Source Han package would only duplicate them.
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      ibm-plex
      # The GitHub release is M PLUS 1 / M PLUS 2, which cover JIS level 2
      # kanji. The OSDN release stops at the older TESTFLIGHT build.
      mplus-outline-fonts.githubRelease
      migu
      migmix
      koruri
      rounded-mgenplus
      yasashisa-gothic
      hachimarupop

      # Public documents and typesetting.
      ipafont
      ipaexfont

      # Rare kanji, variant glyphs and stroke order.
      hanazono
      jigmo
      kanji-stroke-order-font
    ])
    # BIZ UDGothic is in nixpkgs as well, but this set carries BIZ UDMincho too
    # and nixpkgs has no package for it, so taking both from one place keeps the
    # families from appearing twice.
    ++ [ (licensedFonts "windows-japanese") ]
    # macOS ships the Hiragino families itself. Installing them there would give
    # every one of those families a second entry in the font menus.
    ++ lib.optional (!isDarwin) (licensedFonts "macos-japanese");
}
