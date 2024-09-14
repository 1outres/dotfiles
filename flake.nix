{
  description = "NixOS & homa-manager configurations of loutres";

  outputs =
    inputs:
    let
      mkNixosSystem =
        pkgs: system: hostname:
        pkgs.lib.nixosSystem {
          system = system;
          modules = [
            { networking.hostName = "loutres-" + hostname; }
            (./. + "/hosts/${hostname}/nixos.nix")
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                extraSpecialArgs = {
                  inherit inputs;
                };
                users.loutres = (./. + "/hosts/${hostname}/user.nix");
              };
            }
          ];
          specialArgs = {
            inherit inputs;
          };
        };
      mkDarwinSystem =
        pkgs: system: hostname:
        pkgs.lib.darwinSystem {
          system = system;
        };
    in
    {
      nixosConfigurations = {
        desktop = mkNixosSystem inputs.nixpkgs "x86_64-linux" "desktop";
        # mbp-nix = mkDarwinSystem inputs.nixpkgs "aarch64-linux" "mbp-nix";
        # mbp = mkDarwinSystem inputs.nix-darwin "aarch64-darwin" "mbp";
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };

    nixcord = {
      url = "github:kaylorben/nixcord";
    };

  };
}
