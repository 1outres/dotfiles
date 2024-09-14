{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nixcord.homeManagerModules.nixcord
  ];

  programs.nixcord = {
    enable = true;
    config = {
      plugins = {
        forceOwnerCrown.enable = true;
        noPendingCount.enable = true;
        platformIndicators.enable = true;
        fakeNitro.enable = true;
        voiceChatDoubleClick.enable = true;
      };
    };
  };
}
