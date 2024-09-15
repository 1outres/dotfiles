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
            (./. + "/hosts/${hostname}/nixos.nix")
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                extraSpecialArgs = {
                  inherit inputs;
                  inherit system;
                  vars = import (./. + "/hosts/${hostname}/vars.nix");
                };
                users.loutres = (./. + "/hosts/${hostname}/user.nix");
              };
              nixpkgs.overlays = [
                inputs.nixpkgs-wayland.overlay
                inputs.nur.overlay
              ];
            }
          ];
          specialArgs = {
            inherit inputs;
            vars = import (./. + "/hosts/${hostname}/vars.nix");
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
        vaio = mkNixosSystem inputs.nixpkgs "x86_64-linux" "vaio";
        mbp = mkNixosSystem inputs.nixpkgs "aarch64-linux" "mbp";
        # mbp-darwin = mkDarwinSystem inputs.nix-darwin "aarch64-darwin" "mbp-darwin";
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

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
}
