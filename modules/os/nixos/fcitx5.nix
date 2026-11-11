{ pkgs, ... }:

{
  # 日本語入力: fcitx5 + mozc。Wayland ネイティブフロントエンドを使う。
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = [
        pkgs.fcitx5-mozc
        # Fallback for apps the Wayland frontend does not reach, such as some
        # Electron builds and older GTK paths.
        pkgs.fcitx5-gtk
        pkgs.fcitx5-skk
      ];
      waylandFrontend = true;
    };
  };
}
