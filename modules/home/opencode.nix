{ config, ... }:

let
  opencodeDir = "${config.home.homeDirectory}/dotfiles/modules/home/opencode";
  link = path: {
    source = config.lib.file.mkOutOfStoreSymlink "${opencodeDir}/${path}";
    force = true;
  };
in
{
  home.file.".config/opencode/opencode.json" = link "opencode.json";
}
