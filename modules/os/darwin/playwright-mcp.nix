{ username, ... }:

# Playwright MCP のバックエンド。ブラウザを動かすのは常に macOS 側で、
# OrbStack ゲストからは modules/home/playwright-mcp-orbstack.nix が
# `mac` 越しにこのバイナリを起動する。
{
  home-manager.users.${username} =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.playwright-mcp ];
    };
}
