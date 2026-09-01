{ private, ... }:

{
  nix.settings = {
    extra-substituters = [
      "${private.attic.endpoint}/${private.attic.cache}"
    ];
    extra-trusted-public-keys = [
      private.attic.publicKey
    ];
    netrc-file = "/etc/nix/netrc";
  };
}
