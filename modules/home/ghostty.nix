{ lib, ... }:

{
  programs.ghostty = {
    enable = lib.mkDefault false;
    # Ghostty's zsh integration rewrites PS1 by injecting a marker after every
    # newline, which breaks p10k's prompt. p10k emits OSC 133 itself instead
    # (POWERLEVEL9K_TERM_SHELL_INTEGRATION), and also reports title and cwd.
    enableZshIntegration = false;
    package = lib.mkDefault null;
    # The look stays at mkDefault so that a desktop such as chena can theme the
    # terminal to match the rest of the screen.
    settings = {
      app-notifications = "no-clipboard-copy";
      background-blur = lib.mkDefault true;
      background-opacity = lib.mkDefault 0.8;
      clipboard-read = "allow";
      clipboard-write = "allow";
      font-family = lib.mkDefault [
        "Monaspace Krypton NF"
        "M+1Code Nerd Font"
      ];
      keybind = [
        "global:cmd+shift+space=toggle_quick_terminal"
      ];
      quick-terminal-animation-duration = 0;
      quick-terminal-position = "center";
      quick-terminal-screen = "mouse";
      quick-terminal-size = "100%";
      shell-integration = "none";
      theme = "Dracula";
      window-decoration = "none";
    };
  };
}
