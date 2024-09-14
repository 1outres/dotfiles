{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "loutres";
    userEmail = "me@loutres.me";
  };
}
