{ inputs, lib, ... }:

let
  inherit (inputs) aurora;

  # The package set Aurora's own CI builds, so its outputs are in Aurora's
  # signed cache. nixbook is built from the same nixpkgs (flake.nix), which
  # makes the overlaid packages below match that cache as well, as long as
  # nothing here changes them.
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
  # Aurora's package set, so the host stays safe even if the two ever drift
  # apart: the kernel and U-Boot, and the Mesa builds for the FEX and Flatpak
  # guests. They are also the heaviest builds, and the FEX Mesa needs an
  # x86_64-linux builder.
  hardware.asahi.pkgs = lib.mkForce auroraPkgs;
  aurora.fexMesa.package = auroraPkgs.aurora-fex-mesa;
  aurora.flatpak.package = auroraPkgs.aurora-flatpak-gl;

  # Aurora plays trackpad clicks from the host, and on this trackpad the
  # host plays them at full strength, which feels far too hard. These are
  # the strength and softness of the press waveform that the trackpad
  # firmware itself used (feature report 0x22 of the actuator).
  boot.extraModprobeConfig = ''
    options hid_magicmouse haptic_strength=35 haptic_softness=168
  '';
}
