{ config, pkgs, rootDir, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${rootDir}/home-manager/cli/nvim/config";

  home.file.".vim/dein.toml".source = config.lib.file.mkOutOfStoreSymlink ./dein/dein.toml;
  home.file.".vim/dein_lazy.toml".source = config.lib.file.mkOutOfStoreSymlink ./dein/dein_lazy.toml;
}
