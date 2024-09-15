{ pkgs, ...}:
{
  imports = [
    ./alacritty
    ./socials.nix
    ./firefox.nix
  ];
# ++ (if pkgs.system != "aarch64-linux" then [ ./discord ] else []);
}
