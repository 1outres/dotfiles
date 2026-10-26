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

  # Go fetches the private mNi-Cloud modules through the SSH rewrite above, but
  # the public checksum database cannot see them, so `go install` of an mNi tool
  # (such as mnibuilder in each controller's Makefile) fails without this.
  xdg.configFile."go/env".text = ''
    GOPRIVATE=github.com/mNi-Cloud
  '';

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
