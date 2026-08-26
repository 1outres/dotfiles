{ lib, ... }:

{
  programs.ghostty = {
    enable = lib.mkDefault false;
    # Ghostty's zsh integration rewrites PS1 by injecting a marker after every
    # newline, which breaks p10k's prompt. p10k emits OSC 133 itself instead
    # (POWERLEVEL9K_TERM_SHELL_INTEGRATION), and also reports title and cwd.
    enableZshIntegration = false;
    package = lib.mkDefault null;
    settings = {
      app-notifications = "no-clipboard-copy";
      background-blur = true;
      background-opacity = 0.8;
      clipboard-read = "allow";
      clipboard-write = "allow";
      font-family = [
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
