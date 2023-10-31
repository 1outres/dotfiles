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
    set ID (echo SSH DevServer\nCreate New Session | fzf | cut -d: -f1)
  else if test (uname -s) = "Darwin"
    set ID (tmux list-sessions | sed '1iSSH DevServer\nCreate New Session' | fzf | cut -d: -f1)
  else 
    set ID (tmux list-sessions | sed '1iCreate New Session' | fzf | cut -d: -f1)
  end
  if test "$ID" = "Create New Session"
    tmux new-session
  else if test "$ID" = "SSH DevServer"
    ssh dev.cron.home
  else if test -n "$ID"
    tmux attach-session -t "$ID"
  end
end

function create_date_folder
  set DATE (date -Idate | sed -e "s/-/\//g")
  if ! test -d "$HOME/Documents/$DATE"
    mkdir -p "$HOME/Documents/$DATE"
    echo "Created today's folder!"
  end
  cd "$HOME/Documents/$DATE/"
end

if test -z $TMUX && status --is-login
  attach_tmux_session_if_needed
else
  create_date_folder
end
