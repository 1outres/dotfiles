alias l="lazygit"
alias vim="nvim"
alias ls="ls --color -a"
alias :q="exit"
alias k="kubectl"

if test -e /etc/os-release
  # Linux
  alias pbcopy="xsel --clipboard --input"
  alias pbpaste="xsel --clipboard --output"
end

if test (uname -s) = "Darwin"
  eval (/opt/homebrew/bin/brew shellenv)
  alias sed="gsed"
  gpgconf --launch gpg-agent
end

set -x EDITOR $(which nvim)
set -x M3_HOME /opt/maven

set -x GPG_TTY $(tty)
set -x SSH_AUTH_SOCK $(gpgconf --list-dirs agent-ssh-socket)

set -x OS_CLOUD admin

set -x KUBECONFIG $(sh -c "echo `ls ~/.kube/configs/*`" | tr ' ' ':')

set -g theme_display_k8s_context yes
set -g theme_display_k8s_namespace no

alias keymap="echo 'Ctrl+R History';echo 'Ctrl+F ghq repo';echo 'Ctrl+O Open a file with editor';echo 'Ctrl+T Find File';echo 'Alt+C  sub-dir'"

function attach_tmux_session_if_needed
  if test -z (tmux list-sessions)
    if test -n "$SSH_CLIENT"
      set ID (echo Create New Session | fzf | cut -d: -f1)
    else
      set ID (echo SSH DevServer\nCreate New Session | fzf | cut -d: -f1)
    end
  else if test (uname -s) = "Darwin"
    if test -n "$SSH_CLIENT"
      set ID (tmux list-sessions | sed '1iCreate New Session' | fzf | cut -d: -f1)
    else
      set ID (tmux list-sessions | sed '1iSSH DevServer\nCreate New Session' | fzf | cut -d: -f1)
    end
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
    unlink "$HOME/today"
    ln -s "$HOME/Documents/$DATE" "$HOME/today"
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


if test -d ~/.cargo
    fish_add_path $HOME/.cargo/bin
end
create_date_folder

if test -z $TMUX && status --is-login && test -n $INTELLIJ_ENVIRONMENT_READER && test "$TERM" = "alacritty"
  attach_tmux_session_if_needed
else
  set -x __CFBundleIdentifier org.alacritty
end


# Created by `pipx` on 2024-07-07 05:28:48
set PATH $PATH /Users/loutres/.local/bin

set -q KREW_ROOT; and set -gx PATH $PATH $KREW_ROOT/.krew/bin; or set -gx PATH $PATH $HOME/.krew/bin
