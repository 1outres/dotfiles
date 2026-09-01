{ ... }:

{
  imports = [
    ../../modules/home/claude.nix
    ../../modules/home/core.nix
    ../../modules/home/git-ai-commit.nix
    ../../modules/home/lazygit.nix
    ../../modules/home/neovim.nix
    ../../modules/home/opencode.nix
    ../../modules/home/sitka.nix
    ../../modules/home/tmux.nix
    ../../modules/shared/git.nix
    ../../modules/shared/shell.nix
  ];

  home.username = "loutres";
}
