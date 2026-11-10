{ lib, pkgs, ... }:

let
  # macOS ships its own pbcopy. This one writes OSC 52 to the terminal, the one
  # path that reaches the clipboard of the machine in front of the user through
  # tmux, ssh and mosh alike. The selection is always "c" for mosh (see below).
  pbcopy = pkgs.writeShellApplication {
    name = "pbcopy";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      printf '\033]52;c;%s\a' "$(base64 -w0)" >/dev/tty
    '';
  };
in
{
  home.packages = lib.optional pkgs.stdenv.hostPlatform.isLinux pbcopy;

  programs.tmux.extraConfig = ''
    set -g set-clipboard on
    # mosh 1.4.0 only accepts OSC 52 when the selection is exactly "c", but
    # tmux passes on whatever selection the pane sent: empty for its own
    # copy-mode copy, "c" for a sequence forwarded from an app like neovim.
    # So write "c" when the selection is empty and keep it otherwise.
    # ncurses drops an Ms that never reads %p1, so the branch has to read it.
    # Scoped to the TERM that mosh-server sets, so tmux outside mosh keeps
    # the Ms from its own terminfo.
    set -as terminal-overrides ",xterm-256color:Ms=\e]52;%?%p1%l%t%p1%s%ec%;;%p2%s\a"
  '';
}
