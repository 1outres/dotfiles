{ lib, pkgs, ... }:

{
  imports = [ ./fonts.nix ];

  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;

  # Hosts with a JIS keyboard override this with "jp".
  services.xserver.xkb.layout = lib.mkDefault "us";

  # This only reaches localed and the GDM greeter. A GNOME session reads its own
  # dconf key instead, which modules/home/gnome-keyboard.nix sets.
  services.xserver.xkb.options = "ctrl:nocaps";

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

  # 音声出力は PipeWire に統一 (GNOME 標準構成)。
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
