{ lib, pkgs, ... }:

# home-manager runs its activation as a system service, so it has no session
# bus and loads dconf through a private one. The dconf-service of a desktop
# session that is already running therefore never hears about the write: it
# keeps the previous database in memory and rebuilds the whole file from that
# copy on its next write of its own, which silently drops every key home-manager
# just set. The keyboard layout is the visible case — it comes back as "us" on
# the next login. Ending the service makes it read the file again when the
# session next asks for a key.

{
  home.activation.reloadDconfService = lib.hm.dag.entryAfter [ "dconfSettings" ] ''
    run ${pkgs.procps}/bin/pkill --uid "$UID" --exact dconf-service || true
  '';
}
