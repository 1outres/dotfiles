{ config, libs, inputs, ... }:
{
  home.stateVersion = "24.05";
  imports = [
    ../../home-manager/cli/nvim
  ];
}
