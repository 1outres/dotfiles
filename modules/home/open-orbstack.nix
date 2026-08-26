{ ... }:

# OrbStack 同梱の `open` (/opt/orbstack-guest/bin-hiprio/open) を同じ名前で
# 置き換える。同梱版はゲストのパス変換が壊れていて、`open .` は macOS 側の
# cwd (= /) を、`open /home/loutres/x.png` は hostName 由来の存在しない
# マウントパスを開こうとする。
#
# ラッパー越しなら `open .` で Finder、`open image.png` で既定のアプリ
# (プレビューなど) が開き、URL やアプリ名 (`open -a Preview x.png`) は
# パスとして存在しないのでそのまま macOS 側に渡る。
{
  orbstack.hostBridge.commands.open = {
    command = "/usr/bin/open";
  };
}
