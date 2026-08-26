{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nixcord.homeModules.nixcord
  ];

  programs.nixcord = {
    enable = true;

    discord = {
      enable = true;
      vencord = {
        enable = true;
        package = pkgs.vencord;
      };
    };

    config.plugins = {
      forceOwnerCrown.enable = true;
      noPendingCount.enable = true;
      platformIndicators.enable = true;
      fakeNitro.enable = true;
      voiceChatDoubleClick.enable = true;
    };
  };
}
