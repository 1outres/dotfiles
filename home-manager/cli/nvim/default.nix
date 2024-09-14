{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
  home.file.".config/nvim/coc-settings.json".source = ./coc-settings.json;
  home.file.".config/nvim/init.vim".source = ./init.vim;
  home.file.".vim/dein.toml".source = ./dein/dein.toml;
  home.file.".vim/dein_lazy.toml".source = ./dein/dein_lazy.toml;
}
