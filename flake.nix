{
  description = "Cross-platform dotfiles for macOS, NixOS, and Linux";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.numtide.com"
      "https://aurorasilicon.org/nixos-aurora/cache"
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    private.url = "git+ssh://git@github.com/1outres/dotfiles-private.git";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
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

    # No nixpkgs.follows here either, for the same reason: nixbook is built
    # from the nixpkgs Aurora pins (see nixosHosts.nixbook below) and takes
    # its kernel and guest Mesa from Aurora's own package set, so both hit
    # Aurora's signed cache (hosts/nixos/nixbook/aurora.nix).
    aurora.url = "github:aurora-silicon/nixos-aurora/channel-testing";

    my-dsh-plugins = {
      url = "github:1outres/my-dsh-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    chena = {
      url = "github:1outres/chena";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # The prebuilt Rikka desktop and its NixOS module. Its archives are only
    # autoPatchelf'd here, so following our nixpkgs links them against the
    # same Mesa and glibc the rest of the system uses.
    rikka = {
      url = "github:project-rikka/packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    paseo = {
      url = "github:getpaseo/paseo";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # No nixpkgs.follows: the CLI's build takes go_1_24 from the nixpkgs its
    # own flake pins, and our nixpkgs does not have to keep that attribute.
    mni.url = "github:mNi-Cloud/cli";

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
      mkHome = import ./lib/mkHome.nix { inherit inputs; };
      mkNixos = import ./lib/mkNixos.nix { inherit inputs; };
      mkSwitchOutputs = import ./lib/mkSwitchOutputs.nix { inherit inputs self; };

      homeHosts = {
        mbp = {
          hostname = "mbp";
          username = "loutres";
          system = "aarch64-darwin";
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

        home-wsl = {
          hostname = "home-wsl";
          username = "loutres";
          system = "x86_64-linux";
          hostModule = ./hosts/nixos/home-wsl/default.nix;
          homeModule = ./users/loutres/home-home-wsl.nix;
        };

        nixbook = {
          hostname = "nixbook";
          username = "loutres";
          system = "aarch64-linux";
          hostModule = ./hosts/nixos/nixbook/default.nix;
          homeModule = ./users/loutres/home-nixbook.nix;
          # Aurora's overlay rebuilds a lot of packages with their test suites
          # on. Only the nixpkgs Aurora pins yields the same derivations its CI
          # pushes to the Aurora cache; ours would build all of them locally.
          nixpkgs = inputs.aurora.inputs.nixpkgs;
        };
      };

      sanitizeLabel = import ./lib/sanitizeName.nix;

      switchOutputs = forAllSystems (
        system:
        mkSwitchOutputs {
          inherit
            system
            homeHosts
            nixosHosts
            ;
        }
      );
    in
    {
      formatter = forAllSystems (system: (import nixpkgs { inherit system; }).nixfmt-rfc-style);

      apps = lib.mapAttrs (_: outputs: outputs.apps) switchOutputs;

      packages = lib.mapAttrs (_: outputs: outputs.packages) switchOutputs;

      homeConfigurations = lib.mapAttrs (_: mkHome) homeHosts;

      nixosConfigurations = lib.mapAttrs (_: mkNixos) nixosHosts;

      ci.hosts =
        lib.mapAttrsToList (name: h: {
          label = sanitizeLabel name;
          attr = ''homeConfigurations."${name}".activationPackage'';
          inherit (h) system;
        }) homeHosts
        ++ lib.mapAttrsToList (name: h: {
          label = sanitizeLabel name;
          attr = ''nixosConfigurations."${name}".config.system.build.toplevel'';
          inherit (h) system;
        }) nixosHosts;

      nixosModules = modulesIn ./modules/os/nixos;

      homeModules = modulesIn ./modules/home;

      sharedModules = modulesIn ./modules/shared;

      lib = {
        inherit mkHome mkNixos;
      };
    };
}
