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
            inputs.home-manager.nixosModules.home-manager
            (./. + "/hosts/${hostname}/nixos.nix")
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
        mbp-vm = mkNixosSystem inputs.nixpkgs "aarch64-linux" "mbp-vm";
        mbp-nix = mkDarwinSystem inputs.nixpkgs "aarch64-linux" "mbp-nix";
        mbp = mkDarwinSystem inputs.nix-darwin "aarch64-darwin" "mbp";
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

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
  };
}
