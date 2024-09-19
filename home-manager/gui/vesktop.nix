{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vesktop
  ];

  xdg.desktopEntries.vesktop = {
    name = "Vesktop";
    exec = "${pkgs.vesktop.outPath}/bin/vesktop --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime %U";
    terminal = false;
    type = "Application";
    icon = "vesktop";
    categories = ["Network" "InstantMessaging" "Chat"];
  };
}
