{
  osConfig,
  pkgs,
  ...
}:

let
  # ONLYOFFICE walks the font directories itself instead of asking fontconfig,
  # and keeps only the entries readdir reports as regular files, so it drops
  # every symlink without a word. NixOS hands out fonts as symlinks everywhere
  # outside the store, which is why it finds none of them. Real copies are the
  # only way to show it the installed fonts.
  # https://github.com/ONLYOFFICE/core/blob/master/DesktopEditor/common/Directory.cpp
  fontFiles = pkgs.runCommandLocal "fonts-as-regular-files" { } ''
    mkdir -p "$out"
    find ${toString osConfig.fonts.packages} \
      -regex '.*\.\(ttf\|ttc\|otb\|otf\|pcf\|pfa\|pfb\|bdf\)' \
      -exec cp --dereference --force --no-preserve=mode -t "$out" {} +
  '';
in
{
  home.file.".local/share/fonts".source = fontFiles;
}
