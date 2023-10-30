alias l="lazygit"
alias vim="nvim"
alias ls="ls --color -a"
alias sed="gsed"

if test -e /etc/os-release
    # Linux
    alias pbcopy="xsel --clipboard --input"
    alias pbpaste="xsel --clipboard --output"
end

set -x EDITOR $(which nvim)
set -x M3_HOME /opt/maven

eval (/opt/homebrew/bin/brew shellenv)

alias keymap="echo 'Ctrl+R History';echo 'Ctrl+F ghq repo';echo 'Ctrl+O Open a file with editor';echo 'Ctrl+T Find File';echo 'Alt+C  sub-dir'"

nvm use

