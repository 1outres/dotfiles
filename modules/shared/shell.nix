{
  config,
  hostname,
  inputs,
  lib,
  pkgs,
  private,
  ...
}:

let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  kubectlDfPvWithPlugin = pkgs.symlinkJoin {
    name = "kubectl-df-pv-with-plugin";
    paths = [ pkgs.kubectl-df-pv ];
    postBuild = ''
      ln -s df-pv "$out/bin/kubectl-df_pv"
    '';
  };

  kubectxWithKubectlPlugins = pkgs.symlinkJoin {
    name = "kubectx-with-kubectl-plugins";
    paths = [ pkgs.kubectx ];
    postBuild = ''
      ln -s kubectx "$out/bin/kubectl-ctx"
      ln -s kubens "$out/bin/kubectl-ns"
    '';
  };

  kubevirtWithKubectlPlugin = pkgs.symlinkJoin {
    name = "kubevirt-with-kubectl-plugin";
    paths = [ pkgs.kubevirt ];
    postBuild = ''
      ln -s virtctl "$out/bin/kubectl-virt"
    '';
  };

  sternWithKubectlPlugin = pkgs.symlinkJoin {
    name = "stern-with-kubectl-plugin";
    paths = [ pkgs.stern ];
    postBuild = ''
      ln -s stern "$out/bin/kubectl-stern"
    '';
  };

  # orb is an OrbStack VM living on the mbp, so it is only reachable from there.
  tmuxRemoteEntries =
    lib.optional (hostname == "mbp") "SSH orb" ++ lib.optional (hostname != "home-nix") "Mosh home-nix";
in
{
  home.packages = [
    llmAgents.claude-code
    llmAgents.codex
    llmAgents.pi
    pkgs.ansible
    pkgs.argocd
    pkgs.attic-client
    pkgs.ffmpeg
    pkgs.zsh
    pkgs.htop
    pkgs.git
    pkgs.gh
    pkgs.ghq
    pkgs.glow
    pkgs.jq
    pkgs.kubectl
    pkgs.kubectl-cnpg
    kubectlDfPvWithPlugin
    pkgs.kubectl-neat
    pkgs.kubelogin-oidc
    pkgs.kubectl-tree
    pkgs.kubectl-view-secret
    kubectxWithKubectlPlugins
    kubevirtWithKubectlPlugin
    pkgs.lsof
    pkgs.gnumake
    pkgs.mtr
    pkgs.mosh
    pkgs.ngrok
    sternWithKubectlPlugin
    pkgs.speedtest-cli
    pkgs.tailscale
    pkgs.tailspin
    pkgs.tcpdump
    pkgs.tmux
    pkgs.unzip
    pkgs.wget
    pkgs.whois
    pkgs.yq-go
    pkgs.zip
  ]
  ++ lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.netbird;

  home.file.".p10k.zsh".source = ./p10k.zsh;

  programs.fzf = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.direnv =
    let
      # Pin direnv/nix-direnv to a nixpkgs revision whose aarch64-darwin
      # build is on cache.nixos.org. The current flake.lock advanced past
      # a Go bump that has not yet been built by Hydra for aarch64-darwin.
      # Drop this override once Hydra catches up.
      cachedNixpkgs = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/e8ce29b7561372469521b6573be2848c860c2101.tar.gz";
        sha256 = "0mycp2j38czlsy52yjfcz5xjd8vnw5chvj8jm8791wr5rl2v83ba";
      }) { inherit (pkgs) system; };
    in
    {
      enable = true;
      package = cachedNixpkgs.direnv;
      nix-direnv = {
        enable = true;
        package = cachedNixpkgs.nix-direnv;
      };
    };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  programs.bat.enable = true;

  programs.fd.enable = true;

  programs.ripgrep.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };
    syntaxHighlighting.enable = true;
    history = {
      size = 100000;
      save = 100000;
      path = "${config.xdg.dataHome}/zsh/history";
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      l = "lazygit";
      k = "kubectl";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "fzf"
        "git"
        "kubectl"
        "z"
      ];
      theme = "";
    };
    plugins = [
      {
        name = pkgs.zsh-powerlevel10k.pname;
        src = pkgs.zsh-powerlevel10k.src;
        file = "powerlevel10k.zsh-theme";
      }
    ];
    initContent = ''
      [[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

      export EDITOR="nvim"
      export ZED_ALLOW_EMULATED_GPU="1"

      typeset -U path PATH
      path=("$HOME/.bin" "$HOME/go/bin" $path)

      if [[ -d "$HOME/.kube/configs" ]]; then
        typeset -a kubeconfigs
        kubeconfigs=("$HOME"/.kube/configs/*(N))

        if (( ''${#kubeconfigs[@]} > 0 )); then
          export KUBECONFIG="''${(j/:/)kubeconfigs}"
        fi
      fi

      if [[ -n "''${KREW_ROOT:-}" ]]; then
        path+=("$KREW_ROOT/.krew/bin")
      else
        path+=("$HOME/.krew/bin")
      fi

      if command -v rbenv >/dev/null 2>&1; then
        eval "$(rbenv init - zsh)"
      fi

      if command -v netbird >/dev/null 2>&1; then
        eval "$(netbird completion zsh)"
      elif command -v netbird-main >/dev/null 2>&1; then
        eval "$(netbird-main completion zsh)"
      fi

      if command -v gh >/dev/null 2>&1; then
        eval "$(gh completion -s zsh)"
      fi

      path+=("$HOME/flutter/bin")
      path+=("$HOME/.local/bin")

      [[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

      cd() {
        if [[ "$1" == "today" ]]; then
          create_date_folder
          local date_path
          date_path=$(date +%F | tr '-' '/')
          builtin cd "$HOME/Documents/$date_path"
        else
          builtin cd "$@"
        fi
      }

      create_date_folder() {
        local date_path
        date_path=$(date +%F | tr '-' '/')

        if [[ ! -d "$HOME/Documents/$date_path" ]]; then
          mkdir -p "$HOME/Documents/$date_path"

          [[ -L "$HOME/today" || -e "$HOME/today" ]] && rm -f "$HOME/today"
          ln -s "$HOME/Documents/$date_path" "$HOME/today"

          print "Created today's folder!"
        fi
      }

      __tmux_menu_select_entry() {
        local sessions
        local -a entries
        entries=("Create New Session")

        if [[ -z "''${SSH_CLIENT:-}" && ! -d /opt/orbstack-guest ]]; then
          entries=(${lib.escapeShellArgs tmuxRemoteEntries} "Create New Session")
        fi

        sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
        [[ -n "$sessions" ]] && entries+=("''${(@f)sessions}")

        printf "%s\n" "''${entries[@]}" | fzf
      }

      __tmux_menu_run_entry() {
        case "$1" in
          "Create New Session")
            tmux new-session
            ;;
          "SSH orb")
            ssh orb
            ;;
          "Mosh home-nix")
            mosh -- ${lib.escapeShellArg private.lan.devHostIp} env ZSH_AUTO_ATTACH_TMUX=1 zsh -l
            ;;
          *)
            tmux attach-session -t "$1"
            ;;
        esac
      }

      attach_tmux_session_if_needed() {
        if ! command -v tmux >/dev/null 2>&1 || ! command -v fzf >/dev/null 2>&1; then
          return 0
        fi

        local entry
        while entry=$(__tmux_menu_select_entry) && [[ -n "$entry" ]]; do
          __tmux_menu_run_entry "$entry"
        done
      }

      up-line-or-local-history() {
        zle set-local-history 1
        zle up-line-or-history
        zle set-local-history 0
      }
      zle -N up-line-or-local-history

      down-line-or-local-history() {
        zle set-local-history 1
        zle down-line-or-history
        zle set-local-history 0
      }
      zle -N down-line-or-local-history

      bindkey -v

      __fzf_select_history() {
        if ! command -v fzf >/dev/null 2>&1; then
          zle -M "fzf not found"
          return 0
        fi

        local -a fzf_flags
        fzf_flags+=(--reverse)
        [[ -n ''${BUFFER:-} ]] && fzf_flags+=(--query "$BUFFER")

        local selection
        selection=$(builtin fc -ln -r 1 | fzf "''${fzf_flags[@]}")
        if [[ -n "$selection" ]]; then
          BUFFER="$selection"
          CURSOR=''${#BUFFER}
        else
          BUFFER=
          CURSOR=0
        fi

        zle reset-prompt
      }
      zle -N fzf-select-history-widget __fzf_select_history

      __fzf_select_ghq_repository() {
        if ! command -v ghq >/dev/null 2>&1; then
          zle -M "ghq not found"
          return 0
        fi
        if ! command -v fzf >/dev/null 2>&1; then
          zle -M "fzf not found"
          return 0
        fi

        local -a fzf_flags
        [[ -n ''${BUFFER:-} ]] && fzf_flags+=(--query "$BUFFER")

        local line destination
        line=$(ghq list | fzf --reverse "''${fzf_flags[@]}")
        if [[ -n "$line" ]]; then
          destination=$(ghq list --full-path --exact "$line")
          if [[ -d "$destination" ]]; then
            builtin cd -- "$destination"
            zle reset-prompt
          else
            zle -M "directory not found: $destination"
          fi
        fi
      }
      zle -N fzf-select-ghq-repo-widget __fzf_select_ghq_repository

      __fzf_select_kube_context() {
        if ! command -v kubectl >/dev/null 2>&1; then
          zle -M "kubectl not found"
          return 0
        fi
        if ! command -v fzf >/dev/null 2>&1; then
          zle -M "fzf not found"
          return 0
        fi

        local selection
        selection=$(kubectl config get-contexts --no-headers -o name 2>/dev/null | fzf --reverse)
        if [[ -n "$selection" ]]; then
          kubectl config use-context -- "$selection"
        fi
      }
      zle -N fzf-select-kube-context-widget __fzf_select_kube_context

      for map in emacs viins vicmd; do
        bindkey -M "$map" '^R' fzf-select-history-widget
        bindkey -M "$map" '^F' fzf-select-ghq-repo-widget
        bindkey -M "$map" '^K' fzf-select-kube-context-widget
      done

      bindkey '^[OA' up-line-or-local-history
      bindkey '^[OB' down-line-or-local-history

      if [[ -o interactive ]]; then
        create_date_folder

        if [[ "$PWD" == "$HOME" && -z "''${ZSH_AUTOCD_DISABLED:-}" ]]; then
          cd today
        fi

        if [[ -z "''${TMUX:-}" && ( -n "''${ZSH_AUTO_ATTACH_TMUX:-}" || -n "''${GHOSTTY_RESOURCES_DIR:-}" || "''${TERM_PROGRAM:-}" == "ghostty" || "$TERM" == "xterm-ghostty" ) ]]; then
          unset ZSH_AUTO_ATTACH_TMUX
          attach_tmux_session_if_needed
        fi
      fi
    '';
  };
}
