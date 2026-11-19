{ ... }:

# The layout here has to agree with chena.keyboard.layout on "us". The built-in
# JIS keyboard of x13g2 gets its printed layout from keyd instead
# (modules/os/nixos/keyd.nix).
#
# The file is managed rather than left to fcitx5 because fcitx5 rewrites it from
# memory on exit: a layout picked up during one session comes back on the next
# login and takes the whole session with it.

{
  home.file.".config/fcitx5/profile" = {
    force = true;
    text = ''
      [Groups/0]
      # Group Name
      Name=Default
      # Layout
      Default Layout=us
      # Default Input Method
      DefaultIM=mozc

      [Groups/0/Items/0]
      # Name
      Name=keyboard-us
      # Layout
      Layout=

      [Groups/0/Items/1]
      # Name
      Name=mozc
      # Layout
      Layout=

      [GroupOrder]
      0=Default
    '';
  };

  # fcitx5 alone decides whether Japanese input is on. On Linux the Kana and
  # Eisu keys of a Mac or JIS keyboard arrive as Hangul and Hangul_Hanja. The
  # defaults use Hangul as a toggle and Hangul_Hanja as "on", and they pass a
  # key that changes nothing on to mozc. Mozc reads those keys as its own on
  # and off, so it can go into its direct mode while fcitx5 still shows it as
  # active, and then no key brings Japanese back.
  home.file.".config/fcitx5/config" = {
    force = true;
    text = ''
      [Hotkey]
      ConsumeRedundantActivateKeys=True

      [Hotkey/TriggerKeys]
      0=Control+space
      1=Zenkaku_Hankaku

      [Hotkey/ActivateKeys]
      0=Hangul

      [Hotkey/DeactivateKeys]
      0=Hangul_Hanja
    '';
  };

  # Quick Phrase asks for Super+grave. fcitx5 reads the key through the input
  # method channel, so it would take that key from the desktop whenever a text
  # field has the focus.
  home.file.".config/fcitx5/addon/quickphrase.conf" = {
    force = true;
    text = ''
      [Addon]
      Enabled=False
    '';
  };
}
