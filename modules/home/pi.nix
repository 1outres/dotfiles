{ config, inputs, ... }:

{
  imports = [
    ./agents.nix
    inputs.pi-harness.homeManagerModules.default
  ];

  programs.pi-harness = {
    enable = true;
    sourceDirectory = "${config.home.homeDirectory}/ghq/github.com/1outres/pi-harness";
  };
}
