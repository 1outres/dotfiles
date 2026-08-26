{ config, username, ... }:

{
  imports = [
    ./home.nix
    ../../modules/home/open-orbstack.nix
    ../../modules/home/orbstack-host-bridge.nix
    ../../modules/home/paseo.nix
    ../../modules/home/playwright-mcp-orbstack.nix
    ../../modules/home/zathura-orbstack.nix
  ];

  # `orbctl list` の name 列。networking.hostName (orb) とは別物。
  orbstack.hostBridge.machineName = "nixos";

  # OrbStack guest: unify ~/Documents with the macOS host.
  # OrbStack exposes the macOS home at /Users/<user>, so point the guest's
  # ~/Documents at the host's Documents. This keeps the `cd today` /
  # `create_date_folder` helpers (modules/shared/shell.nix) writing to a single
  # shared location instead of a guest-local copy.
  home.file."Documents".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/${username}/Documents";
}
