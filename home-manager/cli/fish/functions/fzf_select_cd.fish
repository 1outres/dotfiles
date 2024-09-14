function fzf_select_cd

  if test (count $argv) = 0
    set fzf_flags --reverse
  else
    set fzf_flags --reverse --query "$argv"
  end

  find . -name "*" -type d | fzf --reverse $fzf_flags | read line

  if [ $line ]
    cd $line
    commandline -f repaint
  end
end
