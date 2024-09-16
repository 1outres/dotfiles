{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "loutres";
    userEmail = "me@loutres.me";

    extraConfig = {
      url."git@github.com:mNi-Cloud/backend.git".insteadOf = "https://github.com/mNi-Cloud/backend";
    };
  };
}
