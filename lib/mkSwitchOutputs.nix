{ inputs, self }:

{
  system,
  darwinHosts ? { },
  nixosHosts ? { },
}:
let
  inherit (inputs.nixpkgs) lib;

  pkgs = import inputs.nixpkgs { inherit system; };

  sanitizeName = import ./sanitizeName.nix;

  nix = "${pkgs.nix}/bin/nix";
  nixEnv = "${pkgs.nix}/bin/nix-env";
  systemProfile = "/nix/var/nix/profiles/system";

  kinds = {
    darwin = {
      hosts = darwinHosts;
      attrPath = name: ''darwinConfigurations."${name}".system'';
      activate = ''
        sudo -H ${nixEnv} --profile ${systemProfile} --set "$result"
        sudo -H "$result/activate"
      '';
    };

    nixos = {
      hosts = nixosHosts;
      attrPath = name: ''nixosConfigurations."${name}".config.system.build.toplevel'';
      activate = ''
        sudo -H ${nixEnv} --profile ${systemProfile} --set "$result"
        sudo -H "$result/bin/switch-to-configuration" switch
      '';
    };
  };

  # The build has to run as the invoking user. This flake pulls private inputs
  # over git+ssh, and root reaches neither the ssh agent that holds the key nor
  # the user's ssh config, so `sudo darwin-rebuild switch` fails while it is
  # still evaluating. Only the activation step below needs root.
  mkSwitch =
    kind: name:
    pkgs.writeShellApplication {
      name = "switch-${sanitizeName name}";
      text = ''
        result=$(${nix} build --no-link --print-out-paths '${self}#${kind.attrPath name}' "$@")
        ${kind.activate}
      '';
    };

  targets = lib.concatMap (
    kind:
    lib.mapAttrsToList (name: host: {
      inherit name kind;
      inherit (host) hostname;
      package = mkSwitch kind name;
    }) (lib.filterAttrs (_: host: host.system == system) kind.hosts)
  ) (lib.attrValues kinds);

  dispatcher = pkgs.writeShellApplication {
    name = "switch";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      nodename=$(uname -n)
      case "''${nodename%%.*}" in
      ${
        lib.concatMapStrings (target: ''
          ${target.hostname}) exec ${lib.getExe target.package} "$@" ;;
        '') targets
      }*)
        echo "error: no switch target for host '$nodename' on ${system}." >&2
        echo "known hosts: ${lib.concatMapStringsSep ", " (target: target.hostname) targets}" >&2
        exit 1
        ;;
      esac
    '';
  };

  packages =
    lib.listToAttrs (map (target: lib.nameValuePair target.package.name target.package) targets)
    // lib.optionalAttrs (targets != [ ]) { switch = dispatcher; };

  descriptions =
    lib.listToAttrs (
      map (
        target:
        lib.nameValuePair target.package.name "Build ${target.name} as the current user, then activate it as root"
      ) targets
    )
    // {
      switch = "Build and activate the configuration matching this machine's hostname";
    };
in
{
  inherit packages;

  apps = lib.mapAttrs (name: package: {
    type = "app";
    program = lib.getExe package;
    meta.description = descriptions.${name};
  }) packages;
}
