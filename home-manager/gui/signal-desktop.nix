{ pkgs, ... }:
{
  home.packages = with pkgs; [
    signal-desktop
  ];

  xdg.desktopEntries.signal-desktop = {
    name = "Signal";
    # waylandサポートを有効化するとfcitxが使えない
    #exec = "${pkgs.signal-desktop.outPath}/bin/signal-desktop --no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
    exec = "${pkgs.signal-desktop.outPath}/bin/signal-desktop --no-sandbox %U";
    terminal = false;
    type = "Application";
    icon = "signal-desktop";
    mimeType = ["x-scheme-handler/sgnl" "x-scheme-handler/signalcaptcha"];
    categories = ["Network" "InstantMessaging" "Chat"];
  };
}
