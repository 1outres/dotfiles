{ lib, username, ... }:

{
  home-manager.users.${username} = { pkgs, ... }: {
    home.packages = [
      pkgs.coreutils
      pkgs.gnused
      pkgs.iproute2mac
    ];

    programs.zsh = {
      initContent = lib.mkBefore ''
        export HOMEBREW_PREFIX="/opt/homebrew"
        export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
        export HOMEBREW_REPOSITORY="/opt/homebrew"

        path=("/opt/homebrew/opt/llvm/bin" "/opt/homebrew/bin" "/opt/homebrew/sbin" $path)

        if [[ -n ''${MANPATH:-} ]]; then
          export MANPATH=":''${MANPATH}"
        fi

        if [[ ":''${INFOPATH:-}:" != *":/opt/homebrew/share/info:"* ]]; then
          export INFOPATH="/opt/homebrew/share/info''${INFOPATH:+:''${INFOPATH}}"
        fi

        [[ -x /usr/libexec/path_helper ]] && eval "$(/usr/libexec/path_helper -s)"

        path=(
          "/etc/profiles/per-user/${username}/bin"
          "/run/current-system/sw/bin"
          "/nix/var/nix/profiles/default/bin"
          $path
        )

        export NVM_DIR="$HOME/.nvm"
        [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"
        [[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
      '';
    };
  };
}
