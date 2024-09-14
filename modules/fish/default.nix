{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.fish;

in
{
  options.modules.fish = {
    enable = mkEnableOption "fish";
  };
  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      shellAliases = {
        ls = "ls --color -a";
      };
      shellAbbrs = {
        l = "lazygit";
        k = "kubectl";
      };
      shellInit = ''
        set -g theme_display_k8s_context yes
        set -g theme_display_k8s_namespace no
        set -x KUBECONFIG $(sh -c "echo `ls ~/.kube/configs/*`" | tr ' ' ':')
        function cd
          if test "$argv[1]" = "today"
            create_date_folder
          else
            builtin cd $argv
          end
        end
      '';
      interactiveShellInit = ''
        create_date_folder
        if test -z $TMUX && status --is-login && test -n $INTELLIJ_ENVIRONMENT_READER && test "$TERM" = "alacritty"
          attach_tmux_session_if_needed
        else
          set -x __CFBundleIdentifier org.alacritty
        end
      '';

      plugins = [
        {
          name = "z";
          src = pkgs.fishPlugins.z.src;
        }
        {
          name = "fzf";
          src = pkgs.fishPlugins.fzf.src;
        }
        {
          name = "bobthefish";
          src = pkgs.fishPlugins.bobthefish.src;
        }
      ];

    };
    home.file.".config/fish/functions/fish_user_key_bindings.fish".source = ./functions/fish_user_key_bindings.fish;
    home.file.".config/fish/functions/fzf_select_cd.fish".source = ./functions/fzf_select_cd.fish;
    home.file.".config/fish/functions/fzf_select_file_to_edit.fish".source = ./functions/fzf_select_file_to_edit.fish;
    home.file.".config/fish/functions/fzf_select_ghq_repository.fish".source = ./functions/fzf_select_ghq_repository.fish;
    home.file.".config/fish/functions/fzf_select_history.fish".source = ./functions/fzf_select_history.fish;
    home.file.".config/fish/functions/fzf_select_kube_context.fish".source = ./functions/fzf_select_kube_context.fish;
    home.file.".config/fish/functions/attach_tmux_session_if_needed.fish".source = ./functions/attach_tmux_session_if_needed.fish;
    home.file.".config/fish/functions/create_date_folder.fish".source = ./functions/create_date_folder.fish;
  };
}
