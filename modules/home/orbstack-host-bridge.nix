{
  config,
  lib,
  pkgs,
  username,
  ...
}:

# macOS 側のコマンドを OrbStack ゲストから呼ぶための土台。
#
# OrbStack 同梱の `mac` / `open` にもゲスト → macOS のパス変換はあるが、
# 変換先のマシン名にゲストの hostName を使うため `orbctl list` の name と
# 食い違うと壊れ、相対パスも macOS 側の cwd (= /) で解決されてしまう。
# ここでは変換を orb-hostpath で自前に行い、`mac` には変換済みの macOS パス
# だけを渡す (/Users/... は `mac` の変換を素通りする)。
#
# 使う側は orbstack.hostBridge.commands に一行足すだけでよい:
#   orbstack.hostBridge.commands.open = { command = "/usr/bin/open"; };

let
  cfg = config.orbstack.hostBridge;

  guestRoot = "${cfg.hostHome}/OrbStack/${cfg.machineName}";

  orbMac = "/opt/orbstack-guest/bin/mac";

  # ゲストのパスを macOS 側から見えるパスに直す。共有マウントはそのまま、
  # ゲスト固有のパスは macOS 側のマウントポイント配下に読み替える。
  # realpath を通すので、ホストのマウントを指すシンボリックリンク
  # (~/dotfiles や mkOutOfStoreSymlink な ~/Documents) は共有側に解決される。
  orbHostPath = pkgs.writeShellApplication {
    name = "orb-hostpath";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      for path in "$@"; do
        abs=$(realpath -m -- "$path")
        case "$abs" in
          ${lib.concatMapStringsSep " | " (root: "${root}/*") cfg.sharedRoots})
            printf '%s\n' "$abs"
            ;;
          /mnt/mac/*)
            printf '%s\n' "''${abs#/mnt/mac}"
            ;;
          *)
            printf '%s\n' "${guestRoot}$abs"
            ;;
        esac
      done
    '';
  };

  # `sh -c` に渡すスクリプト本体。`mac` はコマンド名以降の引数を書き換えるが
  # スクリプト本体は書き換えないので、macOS 側の絶対パスはここに置く。
  hostScript =
    command:
    if command.detach then
      # `mac` が終了すると、その配下で起動したプロセスは道連れになる。ゲスト側の
      # シェルが端末を持つ場合 (= 普通の対話シェル) に顕著で、nohup でも二重
      # フォークでも stdio を閉じても防げない。fork して新しいセッションを作ると
      # 親が launchd (ppid 1) になり、`mac` の生死と無関係に生きる。
      #
      # setsid は macOS に無いので標準の perl で代用する。`launchctl submit` でも
      # 切り離せるが、あれは KeepAlive が既定で効くのでウィンドウを閉じても復活する。
      #
      # perl は PATH 経由で呼ぶ。/usr/bin/perl と絶対パスで書くと、`mac` がここを
      # ゲストのパスと見なして書き換えてしまう (スクリプトの先頭が絶対パスのとき)。
      ''
        if [ ! -x "${command.command}" ]; then
          echo "${command.command} が macOS 側にありません" >&2
          exit 127
        fi

        exec perl -e 'use POSIX; my $pid = fork(); exit 0 if $pid; POSIX::setsid(); open(STDIN, "<", "/dev/null"); open(STDOUT, ">", "/dev/null"); open(STDERR, ">", "/dev/null"); exec @ARGV;' "${command.command}" "$@"
      ''
    else
      ''exec "${command.command}" "$@"'';

  # 引数のうち実在するパスだけを macOS 側のパスに直して渡す。
  # フラグ・URL・アプリ名はパスとして存在しないのでそのまま通る。
  mkHostCommand =
    name: command:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ orbHostPath ];
      # macOS 側で実行するスクリプトはシングルクォートに包んで渡す。中の $ は
      # ゲスト側では展開させないのが正しいので、SC2016 は当てはまらない。
      excludeShellChecks = [ "SC2016" ];
      text = ''
        args=()
        for arg in "$@"; do
          if [ -e "$arg" ]; then
            args+=("$(orb-hostpath "$arg")")
          else
            args+=("$arg")
          fi
        done

        exec ${orbMac} sh -c ${lib.escapeShellArg (hostScript command)} ${name} "''${args[@]}"
      '';
    };

  hostCommands = pkgs.symlinkJoin {
    name = "orbstack-host-commands";
    paths = lib.mapAttrsToList mkHostCommand cfg.commands;
  };
in
{
  options.orbstack.hostBridge = {
    machineName = lib.mkOption {
      type = lib.types.str;
      example = "nixos";
      description = ''
        OrbStack が macOS 側にこのゲストのファイルシステムを公開するときの
        マシン名。`networking.hostName` ではなく `orbctl list` の name 列の値。
      '';
    };

    hostHome = lib.mkOption {
      type = lib.types.str;
      default = "/Users/${username}";
      description = "macOS 側のホームディレクトリ。";
    };

    sharedRoots = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/Users"
        "/Applications"
        "/Library"
        "/Volumes"
        "/private"
      ];
      description = "ゲストと macOS の双方から同じ絶対パスで見える virtiofs マウント。";
    };

    commands = lib.mkOption {
      default = { };
      description = "ゲストに置くラッパーの一覧。属性名がゲスト側のコマンド名になる。";
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            command = lib.mkOption {
              type = lib.types.str;
              example = "/usr/bin/open";
              description = "macOS 側で実行する実体の絶対パス。";
            };

            detach = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = ''
                真なら macOS 側へ切り離して即座に戻る。ウィンドウを開いたまま
                生き続けるプロセス (GUI アプリ) 向け。偽ならホスト側の終了を
                待ち、終了コードと出力をゲストに返す。
              '';
            };
          };
        }
      );
    };
  };

  config = lib.mkIf (cfg.commands != { }) {
    home.packages = [
      orbHostPath
      hostCommands
    ];

    # OrbStack 自身の `open` は /opt/orbstack-guest/bin-hiprio にあり
    # home-manager のパッケージより PATH で優先されるので、プロファイルを
    # PATH の先頭に持ち上げて上書きする。
    #
    # ここで store パスを直接前置してはいけない。世代を切り替えても既存の
    # シェルは古い store パスを掴んだままになり、更新前のラッパーが動き続ける。
    # プロファイルは世代ごとに貼り替わる symlink なので、シェルを開き直さずに
    # 新しい世代が反映される。
    home.sessionPath = [ "${config.home.profileDirectory}/bin" ];
  };
}
