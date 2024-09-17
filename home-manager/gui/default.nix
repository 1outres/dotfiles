{ pkgs, system, ...}:
let
  applications = {
    common = [
      ./packages.nix
      ./alacritty
      ./zed
      ./signal-desktop.nix
      ./firefox.nix
      ./minecraft.nix
    ];
    x86_64-linux = [
      ./discord.nix
      ./spacedrive.nix
    ];
    aarch64-linux = [
      ./vesktop.nix
    ];
  };
in
{
  imports = (applications.common or []) ++ (applications.${system} or []);
}
