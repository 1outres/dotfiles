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
    inherit inputs hostname username system;
    private = inputs.private.values;
  };
in
inputs.darwin.lib.darwinSystem {
  inherit system;
  specialArgs = args;
  modules = [
    ../modules/shared/nix.nix
    ../modules/os/darwin/core.nix
    ../modules/os/darwin/home-manager.nix
    ../modules/os/darwin/fonts.nix
    ../modules/os/darwin/ghostty.nix
    ../modules/os/darwin/shell.nix
    ../modules/os/darwin/defaults.nix
    ../modules/os/darwin/brew.nix
    ../modules/shared/attic.nix
    ../modules/os/darwin/runcat.nix
    ../modules/os/darwin/playwright-mcp.nix
    ../modules/os/darwin/zathura.nix
    ../modules/os/darwin/window-tracker.nix
    ../modules/os/darwin/omniwm.nix
    # ../modules/os/darwin/cloudflare-warp.nix
    hostModule
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = args;
      home-manager.users.${username} = {
        imports = [
          homeModule
        ];
        home.homeDirectory = "/Users/${username}";
      };
    }
  ];
}
