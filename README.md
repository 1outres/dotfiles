# dotfiles

Cross-platform Nix configuration for macOS (nix-darwin), NixOS, and plain Linux
(standalone home-manager).

| Host | System | Kind |
|---|---|---|
| `mbp` | aarch64-darwin | nix-darwin |
| `orb` | aarch64-linux | NixOS in an OrbStack VM |
| `home-nix` | x86_64-linux | NixOS |
| `x13g2` | x86_64-linux | NixOS on a ThinkPad X13 Gen 2 |
| `loutres@linux` | x86_64-linux | standalone home-manager |

```
lib/        builders for each kind of host, plus modulesIn
modules/
  shared/   settings that apply to every host and every module system
  home/     home-manager modules
  os/       NixOS, nix-darwin, and plain-Linux modules
hosts/      per-machine configuration
users/      per-user module sets
```

The reusable modules are exported as flake outputs, so another flake can pick
single pieces out of this one:

```nix
inputs.dotfiles.url = "github:1outres/dotfiles";
# then, in a NixOS module list:
imports = [ inputs.dotfiles.nixosModules.keyd ];
```

`nixosModules`, `darwinModules`, `homeModules`, and `sharedModules` are
generated from the corresponding directories, so every `.nix` file in them is
available under its filename without the extension.

## The private input

Some things cannot be published: LAN addresses, an internal Wi-Fi SSID, SSH
public keys, a binary cache endpoint, and one host whose configuration is
entirely about private infrastructure. They live in a separate repository,
`1outres/dotfiles-private`, which this flake takes as an input.

They are not secrets in the sops-nix sense. Nix needs them while it *evaluates*
the configuration, and sops-nix decrypts at activation time, which is too late.
A separate flake is what makes the split work.

Its values reach the modules through `specialArgs`, alongside `inputs`,
`hostname`, `username`, and `system`. A module that needs one takes `private`
as an argument:

```nix
{ private, ... }:
{
  services.netbird.clients.default.environment.NB_MANAGEMENT_URL =
    private.netbird.managementUrl;
}
```

There is no default for any of them. A missing key fails evaluation rather than
quietly building a host with the wrong address.

### What the private flake has to provide

```nix
{
  values = {
    netbird.managementUrl = "https://netbird.example.com";
    lan.devHostIp = "10.0.0.1";
    mni.hostnames = [ "a.example.com" "b.example.com" ];
    attic = {
      endpoint = "https://attic.example.com";
      cache = "cache-name";
      publicKey = "cache-name:...=";
    };
    wifi.trustedSsids = [ "..." ];
    ssh.authorizedKeys = [ "ssh-ed25519 ..." ];
    git = {
      userName = "...";
      email = "...";
    };
    signing.sshKey = "ssh-ed25519 ...";
    # Relative to $HOME. Claude Code edits its own skills, so ~/.claude points
    # at a working copy on disk rather than at the Nix store.
    claudeDir = "dotfiles-private/claude";
  };

  nixosModules = {
    home-nix = ./hosts/home-nix;
    hardware-x13g2 = ./hardware/x13g2;
  };
}
```

Host modules in the private flake reach back for the shared modules through
`inputs.self.nixosModules`, so they do not need a relative path into this
repository.

## Building a host

The private inputs are `git+ssh://` URLs, so a machine resolves them with the
SSH key it already uses for GitHub. There is nothing else to set up:

```sh
sudo nixos-rebuild switch --flake ~/dotfiles#<host>   # NixOS
sudo darwin-rebuild switch --flake ~/dotfiles#mbp     # macOS
home-manager switch --flake ~/dotfiles#loutres@linux  # plain Linux
```

`~/dotfiles` is the expected checkout path. Two modules symlink into it
directly, so moving the repository elsewhere breaks them.

While editing the private repository, point the input at the working copy
instead of waiting for a push:

```sh
sudo nixos-rebuild switch --flake ~/dotfiles#<host> \
  --override-input private path:$HOME/dotfiles-private
```

Without the override, `nix flake update private` picks up whatever was pushed.

## CI

`.github/workflows/nightly-update.yml` runs `nix flake update`, refreshes the
brew cask hashes, builds every host, and pushes the closures to an attic cache,
so the switch after merging its PR is download-only.

CI has no SSH key, so it rewrites the SSH URLs to HTTPS ones carrying a token
before Nix runs:

```sh
git config --global url."https://x-access-token:${PAT}@github.com/".insteadOf ssh://git@github.com/
```

Nix honours the rewrite when it fetches a git input, and records the original
`ssh://` URL in `flake.lock`, so the token never reaches the lock file or the
Nix store.

It needs these repository secrets. The attic endpoint, cache name, cache public
key, and Discord user id are plain values in the workflow: none of them is a
credential, and masking them only makes a failing run harder to read.

| Secret | What it is |
|---|---|
| `PRIVATE_INPUTS_PAT` | Fine-grained PAT with Contents: Read on `dotfiles-private` and `window-tracker` |
| `ATTIC_TOKEN` | Push token for the cache |
| `DISCORD_WEBHOOK_URL` | Where the "PR opened" notification goes |
