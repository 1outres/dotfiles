function fzf_select_ghq_repository
  set -l query (commandline)

  if test -n $query
    set fzf_flags --query "$query"
  end

  ghq list | fzf --reverse $fzf_flags | read line

  if [ $line ]
    cd (ghq list --full-path --exact $line)
    commandline -f repaint
  end
end
