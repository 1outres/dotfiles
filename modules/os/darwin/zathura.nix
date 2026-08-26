{ username, ... }:

# PDF ビューア本体。nixpkgs の gtk3 は Darwin では quartz バックエンドで
# ビルドされるため XQuartz は要らない。OrbStack ゲストからは
# modules/home/zathura-orbstack.nix が `mac` 越しにこのバイナリを起動する。
{
  home-manager.users.${username} =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.zathura ];
    };
}
