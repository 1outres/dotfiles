{ pkgs, system, ...}:
let
  applications = {
    common = [
      ./alacritty
      ./signal-desktop.nix
      ./developments.nix
      ./firefox.nix
    ];
    x86_64-linux = [
      ./discord.nix
    ];
    aarch64-linux = [
      ./vesktop.nix
    ];
  };
in
{
  imports = (applications.common or []) ++ (applications.${system} or []);
}
