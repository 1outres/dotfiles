{
  inputs,
  pkgs,
  config,
  ...
}:

{
  home.stateVersion = "24.05";
  imports = [
    ./git
  ];
}
