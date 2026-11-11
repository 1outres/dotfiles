{
  config,
  hostname,
  lib,
  osConfig,
  pkgs,
  private,
  ...
}:

# 1Password asks for approval each time a key is used, so a coding agent left
# alone at the desk cannot use ssh or sign commits. Before leaving, load the
# passphrase-protected key with `ssh-add ~/.ssh/id_ed25519`. While this agent
# holds a key, ssh and commit signing use it instead of 1Password. Remove it
# with `ssh-add -D`, or it expires after the lifetime set below.

let
  awayKey = private.signing.awayKeys.${hostname};
  awayKeyFile = pkgs.writeText "ssh-away-key.pub" awayKey;

  agentSocket = "\${XDG_RUNTIME_DIR}/${config.services.ssh-agent.socket}";

  opSshSign = "${osConfig.programs._1password-gui.package}/share/1password/op-ssh-sign";

  agentHasKeys = pkgs.writeShellApplication {
    name = "ssh-away-agent-has-keys";
    runtimeInputs = [ pkgs.openssh ];
    text = ''
      SSH_AUTH_SOCK="${agentSocket}" ssh-add -l >/dev/null
    '';
  };

  # git calls this as `<program> -Y sign -n git -f <key file> -U <file>` to
  # sign and with other -Y actions to verify.
  signer = pkgs.writeShellApplication {
    name = "ssh-away-sign";
    runtimeInputs = [ pkgs.openssh ];
    text = ''
      export SSH_AUTH_SOCK="${agentSocket}"

      if [ "''${1-}" != "-Y" ] || [ "''${2-}" != "sign" ] || ! ssh-add -T ${awayKeyFile} 2>/dev/null; then
        exec ${opSshSign} "$@"
      fi

      args=()
      while [ $# -gt 0 ]; do
        case "$1" in
          -f)
            args+=(-f ${awayKeyFile} -U)
            shift 2
            ;;
          -U)
            shift
            ;;
          *)
            args+=("$1")
            shift
            ;;
        esac
      done
      exec ssh-keygen "''${args[@]}"
    '';
  };
in
{
  services.ssh-agent = {
    enable = true;
    defaultMaximumIdentityLifetime = 12 * 60 * 60;
  };

  # ssh keeps the first IdentityAgent it reads, so this block has to come
  # before the 1Password one under "*".
  programs.ssh.settings.away-agent = lib.hm.dag.entryBefore [ "*" ] {
    header = ''Match exec "${lib.getExe agentHasKeys}"'';
    IdentityAgent = agentSocket;
  };

  programs.git.signing.signer = lib.getExe signer;

  xdg.configFile."git/allowed_signers".text = ''
    ${config.programs.git.settings.user.email} ${awayKey}
  '';
}
