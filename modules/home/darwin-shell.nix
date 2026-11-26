{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.coreutils
    pkgs.gnused
    pkgs.iproute2mac
  ];

  programs.zsh = {
    initContent = lib.mkBefore ''
      # Reload Nix daemon environment if a macOS update wiped /etc/zshrc.
      if [[ -z "''${__ETC_PROFILE_NIX_SOURCED:-}" && -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi

      [[ -x /usr/libexec/path_helper ]] && eval "$(/usr/libexec/path_helper -s)"

      export HOMEBREW_PREFIX="/opt/homebrew"
      export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
      export HOMEBREW_REPOSITORY="/opt/homebrew"

      if [[ -n ''${MANPATH:-} ]]; then
        export MANPATH=":''${MANPATH}"
      fi

      if [[ ":''${INFOPATH:-}:" != *":/opt/homebrew/share/info:"* ]]; then
        export INFOPATH="/opt/homebrew/share/info''${INFOPATH:+:''${INFOPATH}}"
      fi

      path=(
        "$HOME/.nix-profile/bin"
        "${config.xdg.stateHome}/nix/profile/bin"
        "/nix/var/nix/profiles/default/bin"
        "/opt/homebrew/opt/llvm/bin"
        "/opt/homebrew/bin"
        "/opt/homebrew/sbin"
        $path
      )

      export NVM_DIR="$HOME/.nvm"
      [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"
      [[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    '';
  };
}
