{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "loutres";
    userEmail = "me@loutres.me";

    extraConfig = {
      url."git@github.com:mNi-Cloud/backend.git".insteadOf = "https://github.com/mNi-Cloud/backend";
    };

    signing = {
      signByDefault = true;
      key = "A01EACC7A3B5C7C5";
      gpgPath = "${pkgs.gnupg}/bin/gpg";
    };
  };
}
