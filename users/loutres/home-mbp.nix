{ ... }:

{
  imports = [
    ./home.nix
    ../../modules/home/darwin-fonts.nix
    ../../modules/home/darwin-shell.nix
    ../../modules/home/ghostty.nix
  ];

  # Manage only Ghostty's config file here; the app bundle itself is installed
  # outside Nix (modules/home/ghostty.nix keeps package = null).
  programs.ghostty = {
    enable = true;
    # Keep the right Option key for typing special characters.
    settings.macos-option-as-alt = "left";
  };
}
