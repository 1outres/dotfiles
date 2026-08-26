{ pkgs, username, ... }:

let
  # OrbStack ゲストと macOS の双方から同じ絶対パスで見えるため、
  # Mac 側が書いたスクリーンショットやスナップショットを
  # ゲスト側のエージェントがそのまま読める。
  outputDir = "/Users/${username}/.cache/playwright-mcp";

  # `mac` はコマンド名以降の引数をゲストのパスとして書き換えるが、
  # `sh -c` に渡すスクリプト本体は書き換えない。よって macOS 側の
  # 絶対パスはスクリプト内に置く。
  macPlaywrightMcp = "/etc/profiles/per-user/${username}/bin/playwright-mcp";
  orbMac = "/opt/orbstack-guest/bin/mac";

  # macOS 側の cwd はゲストの cwd が存在しないと `/` に落ちる。
  # 相対パス指定のファイル出力を outputDir に収めるため明示的に移動する。
  playwrightMcpMac = pkgs.writeShellScriptBin "playwright-mcp-mac" ''
    exec ${orbMac} sh -c 'mkdir -p "${outputDir}" && cd "${outputDir}" && exec "${macPlaywrightMcp}" --browser chrome --output-dir "${outputDir}" "$@"' playwright-mcp-mac "$@"
  '';
in
{
  home.packages = [ playwrightMcpMac ];
}
