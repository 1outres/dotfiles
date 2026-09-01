{ private, ... }:

{
  nix.settings = {
    extra-substituters = [
      "${private.attic.endpoint}/${private.attic.cache}"
    ];
    extra-trusted-public-keys = [
      private.attic.publicKey
    ];
    # Substituting runs as root, so a token under $HOME never reaches it and
    # every path misses with HTTP 401. Nix only reads this file, it never
    # creates it. Write it on each host before rebuilding:
    #   sudo install -m 600 /dev/stdin /etc/nix/netrc <<<'machine attic.k.loutres.me password <token>'
    netrc-file = "/etc/nix/netrc";
  };
}
