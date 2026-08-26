{ lib, pkgs, ... }:

{
  imports = [ ./ghostty.nix ];

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    # macOS 側は Homebrew 由来の Monaspace / M+ を参照するが、Linux host には
    # nixpkgs で入る Nerd Font しか無いのでバー・ランチャーと同じ物に揃える。
    settings.font-family = lib.mkForce [
      "JetBrainsMono Nerd Font"
      "Noto Sans CJK JP"
    ];
  };
}
