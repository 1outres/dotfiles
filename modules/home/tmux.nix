{ pkgs, hostname, ... }:

let
  # Per-host status line theme color (wfxr/tmux-power `@tmux_power_theme`).
  # Presets: gold redwine moon forest violet snow coral sky everforest,
  # or any hex like '#cb1b45'. No fallback: a new host must be added here.
  statusThemeByHost = {
    mbp = "gold";
    orb = "violet";
    home-nix = "forest";
    x13g2 = "coral";
    linux = "snow";
  };
  statusTheme = statusThemeByHost.${hostname};
in
{
  programs.tmux = {
    enable = true;
    mouse = true;
    terminal = "tmux-256color";
    shell = "${pkgs.zsh}/bin/zsh";
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.sensible;
      }
      {
        plugin = tmuxPlugins.power-theme;
        extraConfig = ''
          set -g @tmux_power_theme '${statusTheme}'
        '';
      }
    ];
    extraConfig = ''
      set -ag terminal-overrides ",ghostty:RGB"
      set -g allow-passthrough on
      set -g extended-keys on
      set -g extended-keys-format csi-u

      bind | split-window -h
      bind - split-window -v

      bind -n C-left previous-window
      bind -n C-right next-window

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      set -g set-clipboard on
      # mosh 1.4.0 only accepts OSC 52 when the selection is "c", but tmux
      # sends it empty. Force "c" so copies reach the clipboard over mosh.
      set -as terminal-overrides ",*:Ms=\E]52;c;%p2%s\007"

      bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"
      bind -n WheelDownPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "send-keys -M"
    '';
  };
}
