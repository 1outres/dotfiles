{ username, ... }:

# ゲストの `zathura` は macOS 側の zathura (modules/os/darwin/zathura.nix) を
# 開くラッパー。ゲストに Linux 版 zathura を入れるとこの名前が衝突する。
{
  orbstack.hostBridge.commands.zathura = {
    command = "/etc/profiles/per-user/${username}/bin/zathura";
    detach = true;
  };
}
