{ private, ... }:

{
  programs.npm = {
    enable = true;
    package = null;
    settings."//registry.npmjs.org/:_authToken" = private.npm.authToken;
  };
}
