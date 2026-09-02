{ ... }:

{
  imports = [
    ./home.nix
    ../../modules/home/discord.nix
    ../../modules/home/element.nix
    # programs.ghostty.enable is set by modules/os/darwin/home-manager.nix,
    # because the app itself comes from environment.systemPackages.
    ../../modules/home/ghostty.nix
    ../../modules/home/ollama.nix
    ../../modules/home/sillytavern.nix
    ../../modules/home/zen-browser.nix
  ];
}
