{ pkgs, ... }:

# Mattermost sets its electron-builder "desktopName" to "Mattermost.Desktop",
# and Electron passes that string to the Wayland compositor as the app_id. The
# installed entry is Mattermost.desktop, so GNOME looks for a file that does not
# exist and the running window matches no application. The entry carries no
# StartupWMClass of its own, so adding one is all it takes.

let
  mattermost = pkgs.symlinkJoin {
    name = "mattermost-desktop-${pkgs.mattermost-desktop.version}";
    paths = [ pkgs.mattermost-desktop ];
    postBuild = ''
      entry=$out/share/applications/Mattermost.desktop
      rm $entry
      cp ${pkgs.mattermost-desktop}/share/applications/Mattermost.desktop $entry
      chmod +w $entry

      if grep -q StartupWMClass $entry; then
        echo "Mattermost now ships a StartupWMClass; drop this override" >&2
        exit 1
      fi

      echo StartupWMClass=Mattermost.Desktop >> $entry
    '';
  };
in
{
  home.packages = [ mattermost ];
}
