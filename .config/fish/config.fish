alias l="lazygit"
alias vim="nvim"
alias ls="ls --color -a"

if test -e /etc/os-release
  # Linux
  alias pbcopy="xsel --clipboard --input"
  alias pbpaste="xsel --clipboard --output"
end

if test (uname -s) = "Darwin"
  eval (/opt/homebrew/bin/brew shellenv)
  alias sed="gsed"
end

set -x EDITOR $(which nvim)
set -x M3_HOME /opt/maven


alias keymap="echo 'Ctrl+R History';echo 'Ctrl+F ghq repo';echo 'Ctrl+O Open a file with editor';echo 'Ctrl+T Find File';echo 'Alt+C  sub-dir'"

function attach_tmux_session_if_needed
  if test -z (tmux list-sessions)
    tmux new-session
    return
  end

  set ID (tmux list-sessions | sed '1iCreate New Session' | fzf | cut -d: -f1)
  if test "$ID" = "Create New Session"
    tmux new-session
  else if test -n "$ID"
    tmux attach-session -t "$ID"
  end
end

if test -z $TMUX && status --is-login
  attach_tmux_session_if_needed
end
