{ inputs, hostname, ... }:
{
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
    };
    users.loutres = (../.. + "/hosts/${hostname}/user.nix");
  };
}
