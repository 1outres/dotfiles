{ inputs, pkgs, ... }:

{
  imports = [ ./agents.nix ];

  home.packages = [ inputs.pi-harness.packages.${pkgs.stdenv.hostPlatform.system}.pi ];
}
