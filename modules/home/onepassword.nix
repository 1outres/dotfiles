{
  config,
  osConfig,
  private,
  ...
}:

# Wires the SSH key kept in 1Password into ssh and git. The desktop app has to
# have its SSH agent switched on for any of this to work, and that setting lives
# in the app rather than here.

let
  signingKey = private.signing.sshKey;

  allowedSigners = "${config.xdg.configHome}/git/allowed_signers";
in
{
  programs.ssh = {
    enable = true;
    # The old defaults are deprecated upstream and only add unrelated settings.
    enableDefaultConfig = false;
    settings."*".IdentityAgent = "~/.1password/agent.sock";
  };

  programs.git = {
    signing = {
      format = "ssh";
      key = signingKey;
      # op-ssh-sign hands the signing over to the desktop app, so the private
      # key never leaves 1Password.
      signer = "${osConfig.programs._1password-gui.package}/share/1password/op-ssh-sign";
      signByDefault = true;
    };

    settings.gpg.ssh.allowedSignersFile = allowedSigners;
  };

  xdg.configFile."git/allowed_signers".text = ''
    ${config.programs.git.settings.user.email} ${signingKey}
  '';
}
