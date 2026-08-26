{ config, pkgs, ... }:

# Playwright MCP server for the hermes agent. It runs here on the host rather
# than inside the hermes container because Chrome needs unprivileged user
# namespaces for its sandbox, and Docker's default seccomp profile blocks
# them — inside the container Chrome only starts with --no-sandbox.
# hermes reaches this over HTTP; its container uses --network=host.

let
  port = 8931;

  # Dedicated profile so the agent keeps its own cookies and logins across
  # restarts, separate from any browser profile used interactively.
  profileDir = "${config.home.homeDirectory}/.local/share/playwright-mcp-hermes";

  chromeWayland = pkgs.writeShellScriptBin "chrome-wayland" ''
    exec ${pkgs.google-chrome}/bin/google-chrome-stable --ozone-platform=wayland "$@"
  '';
in
{
  home.packages = [ chromeWayland ];

  systemd.user.services.playwright-mcp-hermes = {
    Unit = {
      Description = "Playwright MCP server driving Chrome on Wayland for hermes";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = builtins.concatStringsSep " " [
        "${pkgs.playwright-mcp}/bin/playwright-mcp"
        "--port ${toString port}"
        "--host 127.0.0.1"
        # The container connects as 127.0.0.1, which does not match the
        # default host allowlist, so name both spellings.
        "--allowed-hosts 127.0.0.1:${toString port},localhost:${toString port}"
        "--executable-path ${chromeWayland}/bin/chrome-wayland"
      ];

      # The nixpkgs wrapper forces PLAYWRIGHT_MCP_ISOLATED=1 unless
      # PLAYWRIGHT_MCP_USER_DATA_DIR is set, and an isolated profile rejects a
      # user data dir. Passing --user-data-dir on the command line does not
      # satisfy the wrapper, so the profile has to arrive as an env var.
      Environment = [
        "PLAYWRIGHT_MCP_USER_DATA_DIR=${profileDir}"
        "PLAYWRIGHT_MCP_BROWSER=chrome"
        "PLAYWRIGHT_MCP_HEADLESS=false"
        "WAYLAND_DISPLAY=wayland-0"
      ];

      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
