{ inputs, pkgs, ... }:

let
  # Casks whose upstream URL is unversioned (e.g. Spotify), so the hash brew-api
  # ships is unreliable. Hashes here are refreshed nightly by the
  # `.github/workflows/nightly-update.yml` workflow — do not hand-edit unless
  # adding or removing an entry. New entries can be seeded with pkgs.lib.fakeHash
  # ("sha256-AAAA...="); the workflow overwrites it on the next run.
  casksWithHash = builtins.fromJSON (builtins.readFile ./cask-hashes.json);

  mkCaskWithHash =
    name: hash:
    pkgs.brewCasks.${name}.overrideAttrs (old: {
      src = pkgs.fetchurl {
        url = builtins.head old.src.urls;
        inherit hash;
      };
    });
in

{
  nixpkgs.overlays = [
    inputs.brew-nix.overlays.default
  ];

  environment.systemPackages = [
    pkgs.brewCasks."1password"
    pkgs.brewCasks.notion
    pkgs.brewCasks."proton-mail"
    pkgs.brewCasks.nani
    pkgs.brewCasks.slack
    pkgs.brewCasks.orbstack
    pkgs.brewCasks.notion-calendar
    pkgs.brewCasks.todoist-app
    pkgs.brewCasks.skim
    pkgs.brewCasks.obsidian
    pkgs.brewCasks.monitorcontrol
    pkgs.brewCasks.claude
    pkgs.brewCasks.chatgpt
    pkgs.brewCasks.alt-tab
    pkgs.brewCasks.thorium
    pkgs.brewCasks.stats
    pkgs.brewCasks.kap
    pkgs.brewCasks.thunderbird
    pkgs.brewCasks.paseo
    pkgs.brewCasks.thebrowsercompany-dia
    pkgs.brewCasks.mattermost
  ] ++ pkgs.lib.mapAttrsToList mkCaskWithHash casksWithHash;
}
