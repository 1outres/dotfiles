{ config, ... }:

{
  # ONLYOFFICE ships its own font scanner, which reads this directory and
  # /usr/share/fonts and never looks at the fontconfig configuration. The system
  # font directory has to be reachable from here for it to find anything beyond
  # the fonts it bundles.
  home.file.".local/share/fonts".source =
    config.lib.file.mkOutOfStoreSymlink "/run/current-system/sw/share/X11/fonts";
}
