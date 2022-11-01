#!/usr/bin/env bash
set -ue

helpmsg() {
  command echo "Usage: $0 [--help | -h]" 0>&2
  command echo ""
}

link_to_homedir() {
  command echo "backup old dotfiles..."
  if [ ! -d "$HOME/.dotbackup" ];then
    command echo "$HOME/.dotbackup not found. Auto Make it"
    command mkdir "$HOME/.dotbackup"
  fi

  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  local dotdir=$(dirname ${script_dir})
  cd $dotdir
  if [[ "$HOME" != "$dotdir" ]];then

    for f in `find . -path "./.*" -type f`; do
      [[ $f =~ ^\.\/\.git.* ]] && continue
      if [[ -L "$HOME/$f" ]];then
        command rm -f "$HOME/$f"
      fi
      if [[ -e "$HOME/$f" ]];then
      	command mkdir -p "$(dirname "$HOME/.dotbackup/$f")"
        command mv "$HOME/$f" "$HOME/.dotbackup/$f"
      fi
      command ln -snvf "$dotdir/$f" "$HOME/$f"
    done
  else
    command echo "same install src dest"
  fi
}

while [ $# -gt 0 ];do
  case ${1} in
    --debug|-d)
      set -uex
      ;;
    --help|-h)
      helpmsg
      exit 1
      ;;
    *)
      ;;
  esac
  shift
done

link_to_homedir
git config --global include.path "~/.gitconfig_shared"
command echo -e "\e[1;36m Install completed!!!! \e[m"