{
  config,
  lib,
  private,
  ...
}:

let
  gitDir = "${config.home.homeDirectory}/dotfiles/modules/shared/git";
in
{
  home.file.".config/git/ignore" = {
    source = config.lib.file.mkOutOfStoreSymlink "${gitDir}/ignore";
    force = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = private.git.userName;
        email = private.git.email;
      };
      url."git@github.com:mNi-Cloud/".insteadOf = "https://github.com/mNi-Cloud/";
    };
    # Hosts that keep keys in 1Password override this with the ssh format.
    signing.format = lib.mkDefault null;
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
