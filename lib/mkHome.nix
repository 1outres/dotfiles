{ inputs }:

{
  hostname,
  username,
  system,
  homeModule ? (../users + "/${username}/home.nix"),
  nixpkgs ? inputs.nixpkgs,
}:
let
  inherit (nixpkgs) lib;
  isDarwin = lib.hasSuffix "-darwin" system;
  homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = import ../overlays;
  };
  args = {
    inherit
      inputs
      hostname
      username
      system
      ;
    private = inputs.private.values;
  };
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = args;
  modules = [
    homeModule
    {
      home = {
        username = lib.mkDefault username;
        homeDirectory = lib.mkDefault homeDirectory;
      };
    }
  ];
}
