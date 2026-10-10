{
  config,
  pkgs,
  username,
  ...
}:

let
  # The wrapper would otherwise put its own codex, git and gh first on PATH,
  # shadowing the newer codex (and claude) from the user's home-manager profile.
  t3code = pkgs.t3code.override {
    enableCodex = false;
    enableGit = false;
    enableGitHub = false;
  };
  port = 3773;
in
{
  # The CLI too, so `t3 pair` can mint pairing tokens for the running server.
  environment.systemPackages = [ t3code ];

  # T3 Code (web GUI for coding agents) as a headless server. It runs as the
  # login user so agents see the same ~/.claude, ~/.codex and repositories, and
  # keeps its state in the default ~/.t3. Clients pair with a token from
  # `t3 pair`; the server prints the first pairing details to the journal.
  #
  # With WSL mirrored networking the port is also behind the Windows (Hyper-V)
  # firewall, which needs its own rule.
  systemd.services.t3code = {
    description = "T3 Code server";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    # Agents and the git tooling come from the user's profile, as in a login
    # shell.
    path = [
      "/etc/profiles/per-user/${username}"
      "/run/current-system/sw"
    ];

    environment.T3CODE_TELEMETRY_ENABLED = "false";

    serviceConfig = {
      User = username;
      Group = "users";
      WorkingDirectory = config.users.users.${username}.home;
      ExecStart = "${t3code}/bin/t3 serve --host 0.0.0.0 --port ${toString port} --no-browser";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
