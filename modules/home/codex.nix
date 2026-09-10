{
  config,
  lib,
  pkgs,
  ...
}:

let
  python = pkgs.python3.withPackages (ps: [ ps.tomlkit ]);
in
{
  imports = [ ./agents.nix ];

  # Merge only managed keys; keep credentials and host state outside Git and the store.
  home.activation.codexSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${python}/bin/python ${./codex/merge-settings.py} \
      ${lib.escapeShellArg "${config.agents.privateDirectory}/codex/config.toml"} \
      ${lib.escapeShellArg "${config.home.homeDirectory}/.codex/config.toml"}
  '';
}
