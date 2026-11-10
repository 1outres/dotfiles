{ inputs, lib, ... }:

let
  inherit (inputs) aurora;

  # The package set Aurora's own CI builds, so its outputs are in Aurora's
  # signed cache. A derivation built from this flake's nixpkgs never matches
  # that cache, even with the same Aurora overlay.
  auroraPkgs = aurora.nixosConfigurations.aurora-minimal.pkgs;
in
{
  imports = [
    aurora.inputs.apple-silicon.nixosModules.default
    aurora.nixosModules.default
    aurora.nixosModules.image
    aurora.nixosModules.installed
  ];

  nixpkgs.overlays = [
    aurora.inputs.apple-silicon.overlays.default
    aurora.overlays.default
  ];

  # Only take packages that share no libraries with the host userspace from
  # Aurora's package set, so mixing two nixpkgs stays safe: the kernel and
  # U-Boot, and the Mesa builds for the FEX and Flatpak guests. They are also
  # the heaviest builds, and the FEX Mesa needs an x86_64-linux builder.
  hardware.asahi.pkgs = lib.mkForce auroraPkgs;
  aurora.fexMesa.package = auroraPkgs.aurora-fex-mesa;
  aurora.flatpak.package = auroraPkgs.aurora-flatpak-gl;
}
