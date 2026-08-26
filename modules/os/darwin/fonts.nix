{ lib, pkgs, ... }:

{
  fonts.packages = [
    pkgs.monaspace
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}
