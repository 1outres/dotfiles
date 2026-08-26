{ inputs }:

{
  hostname,
  username,
  system,
  homeDirectory,
  homeModule ? (../users + "/${username}/home.nix"),
  hostModules ? [ ],
}:
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = import inputs.nixpkgs {
    inherit system;
  };
  extraSpecialArgs = {
    inherit inputs hostname username system;
    private = inputs.private.values;
  };
  modules = [
    ../modules/shared/nix.nix
    ../modules/os/linux/core.nix
    homeModule
    {
      home.homeDirectory = homeDirectory;
    }
  ] ++ hostModules;
}
