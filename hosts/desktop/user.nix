{
  config,
  lib,
  inputs,
  ...
}:

{
  home.stateVersion = "24.05";
  imports = [
    ../../home-manager/cli
    ../../home-manager/desktop
    ../../home-manager/gui
  ];
}
