{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  # Yu Gothic, Meiryo, MS Gothic/Mincho, BIZ UD and UD Digi Kyokasho are
  # licensed with Windows and cannot be redistributed, so the files live in the
  # private flake instead of this repository.
  windows-japanese-fonts =
    pkgs.runCommandLocal "windows-japanese-fonts"
      {
        meta = {
          description = "Japanese fonts that ship with Windows";
          license = lib.licenses.unfree;
          platforms = lib.platforms.all;
        };
      }
      ''
        install -Dm444 -t "$out/share/fonts/truetype" \
          ${inputs.private.fonts.windows-japanese}/*.ttc
      '';
in
{
  fonts.packages = [ windows-japanese-fonts ];
}
