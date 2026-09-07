{ pkgs, ... }:

{
  # ONLYOFFICE and other apps with their own font scanner only look at the
  # standard font directories, so the fonts have to exist as files in one
  # place rather than only as fontconfig entries.
  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    # Nerd Font glyphs are needed by waybar / wofi / hyprlock.
    nerd-fonts.jetbrains-mono

    # Japanese text and UI. Noto Sans/Serif CJK JP are the same typefaces as
    # Source Han Sans/Serif, and their variable builds expose every weight from
    # Thin to Black, so a separate Source Han package would only duplicate them.
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    ibm-plex
    biz-ud-gothic
    # The GitHub release is M PLUS 1 / M PLUS 2, which cover JIS level 2 kanji.
    # The OSDN release stops at the older TESTFLIGHT build.
    mplus-outline-fonts.githubRelease
    migu
    migmix
    koruri
    rounded-mgenplus
    yasashisa-gothic
    hachimarupop

    # Public documents and typesetting.
    ipafont
    ipaexfont

    # Rare kanji, variant glyphs and stroke order.
    hanazono
    jigmo
    kanji-stroke-order-font
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
