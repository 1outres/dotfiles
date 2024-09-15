{ pkgs, system, ...}:
let
  applications = {
    common = [
      ./alacritty
      ./socials.nix
      ./developments.nix
      ./firefox.nix
    ];
    x86_64-linux = [
      ./discord
    ];
    aarch64-linux = [
      ./vesktop.nix
    ];
  };
in
{
  imports = (applications.common or []) ++ (applications.${system} or []);
}
