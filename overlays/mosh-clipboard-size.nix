# mosh 1.4.0 cuts every OSC string at 16 KiB, so a larger OSC 52 copy reaches
# the terminal as broken base64 and the clipboard does not change. Raise the
# limit to tmux's default input-buffer-size, so tmux sets the real limit. Both
# ends need this: mosh-server and mosh-client parse the stream with the same
# code. A large copy stays in mosh's screen state until the next copy, and
# each redraw costs more CPU while it is there.
final: prev: {
  mosh = prev.mosh.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/terminal/terminaldispatcher.cc \
        --replace-fail "MAXIMUM_CLIPBOARD_SIZE = 16*1024" "MAXIMUM_CLIPBOARD_SIZE = 1024*1024"
    '';
  });
}
