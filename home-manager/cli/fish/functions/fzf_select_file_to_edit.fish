function fzf_select_file_to_edit
  if test (count $argv) = 0
    set fzf_flags --reverse
  else
    set fzf_flags --reverse --query "$argv"
  end

  fzf $fzf_flags | read line

  if [ $line ]
    vim $line
    commandline -f repaint
  end
end
