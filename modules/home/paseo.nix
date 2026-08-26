{ inputs, pkgs, ... }:

{
  # Paseo CLI (orchestrator for coding agents), packaged by the upstream flake.
  home.packages = [ inputs.paseo.packages.${pkgs.stdenv.hostPlatform.system}.paseo ];

  # Default client connection so --host / password need not be passed each time:
  # the CLI reads PASEO_HOST and PASEO_PASSWORD from the environment. The secret
  # is kept out of the Nix store / git — source an out-of-band file if present.
  # Create it on client machines (e.g. orb):
  #   mkdir -p ~/.config/paseo
  #   cat > ~/.config/paseo/env <<'EOF'
  #   export PASEO_HOST="tcp://<daemon-host>:6767"
  #   export PASEO_PASSWORD="your-password"
  #   EOF
  #   chmod 600 ~/.config/paseo/env
  programs.zsh.initContent = ''
    paseo_env="''${XDG_CONFIG_HOME:-$HOME/.config}/paseo/env"
    [[ -r "$paseo_env" ]] && source "$paseo_env"
    unset paseo_env
  '';
}
