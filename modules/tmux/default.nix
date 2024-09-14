{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.tmux;

in
{
  options.modules.tmux = {
    enable = mkEnableOption "tmux";
  };
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      extraConfig = ''
        set-option -g mouse on

        bind | split-window -h
        bind - split-window -v

        bind -n C-left previous-window
        bind -n C-right next-window

        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
      '';
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.sensible;
        }
        {
          plugin = tmuxPlugins.power-theme;
        }
      ];
    };
  };
}
