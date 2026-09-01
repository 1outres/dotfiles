{ inputs, pkgs, ... }:

# Claude Desktop reports the Wayland app_id "com.anthropic.Claude" while its own
# desktop entry declares StartupWMClass=claude-desktop. GNOME compares the two
# and finds no match, so the running window belongs to no application and the
# dock shows a generic icon.
#
# The entry is replaced through XDG_DATA_HOME rather than by rebuilding the
# package around a patched copy: upstream ships $out/share as a symlink into
# another store path, so writing a single file under it hits a read-only store.

let
  upstream = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop;

  desktopEntry = pkgs.runCommand "claude-desktop.desktop" { } ''
    substitute ${upstream}/share/applications/claude-desktop.desktop $out \
      --replace-fail StartupWMClass=claude-desktop StartupWMClass=com.anthropic.Claude
  '';
in
{
  home.packages = [ upstream ];

  xdg.dataFile."applications/claude-desktop.desktop".source = desktopEntry;
}
