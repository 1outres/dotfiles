{ ... }:

{
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        forcePushWithLease = true;
      };
    };
  };
}
