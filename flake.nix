{
  description = "Cross-platform dotfiles for macOS, NixOS, and Linux";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    private.url = "git+ssh://git@github.com/1outres/dotfiles-private.git";

    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord = {
      url = "github:FlameFlag/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # No nixpkgs.follows here on purpose: the numtide binary cache only has
    # builds made against the nixpkgs this flake pins, so following ours would
    # rebuild every agent from source.
    llm-agents.url = "github:numtide/llm-agents.nix";

    paseo = {
      url = "github:getpaseo/paseo";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # No nixpkgs.follows here on purpose: sitka builds with buildGo125Module,
    # which the nixpkgs it pins is known to have. Following ours would break
    # the build whenever unstable retires that builder.
    sitka.url = "github:1outres/sitka";

    window-tracker = {
      url = "git+ssh://git@github.com/1outres/window-tracker.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Not MarceColl/zen-browser-flake, which the old configuration used: that
    # repository stopped being updated in October 2024.
    #
    # home-manager.follows matters here: the flake's home module reads
    # mkFirefoxModule.nix out of its own home-manager input, so without this it
    # would mix a second home-manager version into our module tree.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.brew-api.follows = "brew-api";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = lib.genAttrs systems;
      modulesIn = import ./lib/modulesIn.nix lib;
      mkDarwin = import ./lib/mkDarwin.nix { inherit inputs; };
      mkNixos = import ./lib/mkNixos.nix { inherit inputs; };
      mkHome = import ./lib/mkHome.nix { inherit inputs; };
      mkSwitchOutputs = import ./lib/mkSwitchOutputs.nix { inherit inputs self; };

      darwinHosts = {
        mbp = {
          hostname = "mbp";
          username = "loutres";
          system = "aarch64-darwin";
          hostModule = ./hosts/darwin/mbp/default.nix;
          homeModule = ./users/loutres/home-mbp.nix;
        };
      };

      nixosHosts = {
        orb = {
          hostname = "orb";
          username = "loutres";
          system = "aarch64-linux";
          hostModule = ./hosts/nixos/orb/default.nix;
          homeModule = ./users/loutres/home-orb.nix;
        };

        home-nix = {
          hostname = "home-nix";
          username = "loutres";
          system = "x86_64-linux";
          hostModule = inputs.private.nixosModules.home-nix;
          homeModule = ./users/loutres/home-home-nix.nix;
        };

        x13g2 = {
          hostname = "x13g2";
          username = "loutres";
          system = "x86_64-linux";
          hostModule = ./hosts/nixos/x13g2/default.nix;
          homeModule = ./users/loutres/home-x13g2.nix;
        };
      };

      homeHosts = {
        "loutres@linux" = {
          hostname = "linux";
          username = "loutres";
          system = "x86_64-linux";
          homeDirectory = "/home/loutres";
          hostModules = [
            ./hosts/linux/default.nix
          ];
        };
      };

      sanitizeLabel = import ./lib/sanitizeName.nix;

      switchOutputs = forAllSystems (
        system:
        mkSwitchOutputs {
          inherit
            system
            darwinHosts
            nixosHosts
            homeHosts
            ;
        }
      );
    in
    {
      formatter = forAllSystems (system: (import nixpkgs { inherit system; }).nixfmt-rfc-style);

      apps = lib.mapAttrs (_: outputs: outputs.apps) switchOutputs;

      packages = lib.mapAttrs (_: outputs: outputs.packages) switchOutputs;

      darwinConfigurations = lib.mapAttrs (_: mkDarwin) darwinHosts;

      nixosConfigurations = lib.mapAttrs (_: mkNixos) nixosHosts;

      homeConfigurations = lib.mapAttrs (_: mkHome) homeHosts;

      ci.hosts =
        lib.mapAttrsToList (name: h: {
          label = sanitizeLabel name;
          attr = ''darwinConfigurations."${name}".system'';
          inherit (h) system;
        }) darwinHosts
        ++ lib.mapAttrsToList (name: h: {
          label = sanitizeLabel name;
          attr = ''nixosConfigurations."${name}".config.system.build.toplevel'';
          inherit (h) system;
        }) nixosHosts
        ++ lib.mapAttrsToList (name: h: {
          label = sanitizeLabel name;
          attr = ''homeConfigurations."${name}".activationPackage'';
          inherit (h) system;
        }) homeHosts;

      nixosModules = modulesIn ./modules/os/nixos;

      darwinModules = modulesIn ./modules/os/darwin;

      homeModules = modulesIn ./modules/home;

      sharedModules = modulesIn ./modules/shared;

      lib = {
        inherit mkDarwin mkNixos mkHome;
      };
    };
}
