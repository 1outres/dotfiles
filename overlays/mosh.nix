# Backport of NixOS/nixpkgs#568002. The m4 macros that mosh ships are old and
# force -std=gnu++17, but protobuf with abseil 20260817 needs C++20 (the GCC 16
# default). Drop this overlay once nixos-unstable includes that PR.
final: prev: {
  mosh = prev.mosh.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ final.autoconf-archive ];
    postPatch = ''
      rm -rf m4
    ''
    + old.postPatch;
  });
}
