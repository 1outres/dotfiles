{ inputs, pkgs, ... }:

# Claude Desktop reports the Wayland app_id "com.anthropic.Claude" while its own
# desktop entry declares StartupWMClass=claude-desktop. GNOME compares the two
# and finds no match, so the running window belongs to no application and the
# dock shows a generic icon.

let
  upstream = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop;

  claudeDesktop = pkgs.symlinkJoin {
    name = "claude-desktop-${upstream.version}";
    paths = [ upstream ];
    postBuild = ''
      rm $out/share/applications/claude-desktop.desktop
      substitute ${upstream}/share/applications/claude-desktop.desktop \
        $out/share/applications/claude-desktop.desktop \
        --replace-fail StartupWMClass=claude-desktop StartupWMClass=com.anthropic.Claude
    '';
  };
in
{
  home.packages = [ claudeDesktop ];
}
