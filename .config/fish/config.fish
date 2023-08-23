alias l="lazygit"
alias vim="nvim"
alias ls="ls --color -a"

alias Gnome="XDG_SESSION_TYPE=wayland dbus-run-session gnome-session"

function fish_user_key_bindings
  bind \cr 'fzf_select_history (commandline -b)'
  bind \cf fzf_select_ghq_repository
  bind \co fzf_select_file_to_edit
end

if test -e /etc/os-release
    # Linux
    alias pbcopy="xsel --clipboard --input"
    alias pbpaste="xsel --clipboard --output"
end

set -x EDITOR /usr/sbin/nvim
set -x M3_HOME /opt/maven

alias keymap="echo 'Ctrl+R History';echo 'Ctrl+F ghq repo';echo 'Ctrl+O Open a file with editor';echo 'Ctrl+T Find File';echo 'Alt+C  sub-dir'"

nvm use
