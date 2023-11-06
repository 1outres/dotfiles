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

set -x GPG_TTY $(tty)
gpgconf --launch gpg-agent
set -x SSH_AUTH_SOCK $(gpgconf --list-dirs agent-ssh-socket)

alias keymap="echo 'Ctrl+R History';echo 'Ctrl+F ghq repo';echo 'Ctrl+O Open a file with editor';echo 'Ctrl+T Find File';echo 'Alt+C  sub-dir'"

function create_date_folder
  set DATE (date -Idate | sed -e "s/-/\//g")
  if ! test -d "$HOME/Documents/$DATE"
    mkdir -p "$HOME/Documents/$DATE"
    echo "Created today's folder!"
  end
  cd "$HOME/Documents/$DATE/"
end

function cd
  if test "$argv[1]" = "today"
    create_date_folder
  else
    builtin cd $argv
  end
end

if test -z $TMUX && status --is-login
  attach_tmux_session_if_needed
else
  create_date_folder
end

