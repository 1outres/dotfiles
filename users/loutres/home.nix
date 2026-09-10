{ ... }:

{
  imports = [
    ../../modules/home/claude.nix
    ../../modules/home/codex.nix
    ../../modules/home/core.nix
    ../../modules/home/git-ai-commit.nix
    ../../modules/home/lazygit.nix
    ../../modules/home/neovim.nix
    ../../modules/home/pi.nix
    ../../modules/home/sitka.nix
    ../../modules/home/tmux.nix
    ../../modules/shared/git.nix
    ../../modules/shared/shell.nix
  ];

  home.username = "loutres";
}
