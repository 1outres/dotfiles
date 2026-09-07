{ pkgs, ... }:

{
  imports = [ ../../shared/fonts.nix ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    # Nerd Font glyphs are needed by waybar / wofi / hyprlock.
    nerd-fonts.jetbrains-mono
  ];

  # The Noto Sans CJK variants share one priority, so without an explicit order
  # Japanese text can end up drawn with the SC (simplified Chinese) glyphs.
  fonts.fontconfig.defaultFonts = {
    serif = [
      "Noto Serif CJK JP"
      "Noto Color Emoji"
    ];
    sansSerif = [
      "Noto Sans CJK JP"
      "Noto Color Emoji"
    ];
    monospace = [
      "JetBrainsMono Nerd Font"
      "Noto Color Emoji"
    ];
    emoji = [ "Noto Color Emoji" ];
  };
}
