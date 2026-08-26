{ pkgs, ... }:

# Element reports the Wayland app_id "element" while its own desktop entry
# declares StartupWMClass=Element. GNOME compares the two case-sensitively, so
# the running window matches no application and the dock falls back to a generic
# icon. Patching the entry is enough; the app_id itself is fine.

let
  element = pkgs.symlinkJoin {
    name = "element-desktop-${pkgs.element-desktop.version}";
    paths = [ pkgs.element-desktop ];
    postBuild = ''
      rm $out/share/applications/element-desktop.desktop
      substitute ${pkgs.element-desktop}/share/applications/element-desktop.desktop \
        $out/share/applications/element-desktop.desktop \
        --replace-fail StartupWMClass=Element StartupWMClass=element
    '';
  };
in
{
  home.packages = [ element ];
}
