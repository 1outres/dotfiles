function attach_tmux_session_if_needed
  if test -z (tmux list-sessions)
    if test -n "$SSH_CLIENT"
      set ID (echo Create New Session | fzf | cut -d: -f1)
    else
      set ID (echo SSH DevServer\nCreate New Session | fzf | cut -d: -f1)
    end
  else
    if test -n "$SSH_CLIENT"
      set ID (tmux list-sessions | sed '1iCreate New Session' | fzf | cut -d: -f1)
    else
      set ID (tmux list-sessions | sed '1iSSH DevServer\nCreate New Session' | fzf | cut -d: -f1)
    end
  end
  if test "$ID" = "Create New Session"
    tmux new-session
  else if test "$ID" = "SSH DevServer"
    ssh loutres@10.225.128.250
  else if test -n "$ID"
    tmux attach-session -t "$ID"
  end
end
