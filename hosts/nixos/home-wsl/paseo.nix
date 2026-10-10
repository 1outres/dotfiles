{
  inputs,
  pkgs,
  username,
  ...
}:

let
  userHome = "/home/${username}";
  kubeconfigs = map (name: "${userHome}/.kube/configs/${name}") [
    "home-k3s"
    "mni-cloud"
    "mni-staging"
    "punisute-prod"
  ];
  # Runs Claude Code on a subscription OAuth token (`claude setup-token`)
  # instead of the login in ~/.claude, for the claude-sub-token Paseo provider.
  # The token is not in secrets.env, because every agent gets that environment.
  # Paseo runs this as the daemon user, so that user must be able to read it:
  #   sudo install -m 600 -o loutres -g users /dev/stdin /etc/paseo/claude-oauth-token <<<'sk-ant-oat01-...'
  claudeSubTokenFile = "/etc/paseo/claude-oauth-token";
  claudeSubTokenWrapper = pkgs.writeShellApplication {
    name = "claude-sub-token";
    text = ''
      token=$(<"${claudeSubTokenFile}")
      if [[ -z "$token" ]]; then
        echo "claude-sub-token: ${claudeSubTokenFile} is empty" >&2
        exit 1
      fi
      export CLAUDE_CODE_OAUTH_TOKEN="$token"
      exec claude "$@"
    '';
  };
in
{
  imports = [
    inputs.paseo.nixosModules.paseo
  ];

  environment.systemPackages = [ claudeSubTokenWrapper ];

  # Paseo daemon (orchestrator for coding agents) as a systemd service.
  #
  # Remote access goes through an external reverse proxy that terminates TLS for
  # paseo.netbird.loutres.me and reaches this daemon over NetBird. The daemon
  # itself speaks plain HTTP; TLS is the proxy's job.
  services.paseo = {
    enable = true;

    user = username;
    group = "users";

    # Plain HTTP on all interfaces. The reverse proxy and password auth — not
    # TLS here — protect remote access. NixOS-WSL turns the NixOS firewall off,
    # so openFirewall has no effect here; inbound filtering is the Windows
    # (Hyper-V) firewall's job.
    listenAddress = "0.0.0.0";
    port = 6767;
    openFirewall = true;

    # Allow the proxied public hostname through the Host-header / DNS-rebinding
    # check. Loopback and raw IPs stay permitted by default.
    hostnames = [ "paseo.netbird.loutres.me" ];

    # `settings` stays unset: it would overwrite config.json on every start and
    # drop plugin registrations and toggles made from the CLI or the app.
    # config.json is runtime state owned by Paseo and is not tracked in git.
    # It must keep daemon.cors.allowedOrigins for the proxied domain,
    # features.webUi.enabled, and agents.providers.claude-sub-token
    # (extends "claude") with command /run/current-system/sw/bin/claude-sub-token.

    # No external relay: traffic stays on LAN / NetBird.
    relay.enable = false;
  };

  # Password auth, kept out of the Nix store / git: systemd reads PASEO_PASSWORD
  # from a root-owned file managed out of band. Create it before (re)starting:
  #   sudo install -m 600 -o root -g root /dev/stdin /etc/paseo/secrets.env <<<'PASEO_PASSWORD=...'
  # The unit stays stopped until this file exists, so the daemon is never exposed
  # without a password. PASEO_PASSWORD (plaintext) is bcrypt-hashed at startup.
  systemd.services.paseo.serviceConfig.EnvironmentFile = "/etc/paseo/secrets.env";
  # No SSH_AUTH_SOCK yet: home-nix pointed it at the GNOME gcr agent, which WSL
  # does not run. Add it once this host has an agent.
  systemd.services.paseo.environment.KUBECONFIG = builtins.concatStringsSep ":" kubeconfigs;
}
