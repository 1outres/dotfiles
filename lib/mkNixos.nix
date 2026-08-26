{ inputs }:

{
  hostname,
  username,
  system,
  hostModule,
  homeModule ? (../users + "/${username}/home.nix"),
}:
let
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
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = args;
  modules = [
    ../modules/shared/nix.nix
    ../modules/os/nixos/core.nix
    hostModule
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      # Activation refuses to clobber a file it does not own, which turns any
      # hand-written dotfile into a failed switch. Rename it instead.
      home-manager.backupFileExtension = "pre-hm";
      home-manager.extraSpecialArgs = args;
      home-manager.users.${username} = {
        imports = [
          homeModule
        ];
        home.homeDirectory = "/home/${username}";
      };
    }
  ];
}
