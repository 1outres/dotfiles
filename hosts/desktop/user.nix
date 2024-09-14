{
  config,
  lib,
  inputs,
  ...
}:

{
  imports = [ ../../modules/default.nix ];
  config.modules = {
    git.enable = true;
    fish.enable = true;
    packages.enable = true;
    tmux.enable = true;
  };
}
