{ inputs, pkgs, ... }:

{
  home.packages = [
    inputs.mni.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
