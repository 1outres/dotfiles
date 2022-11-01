alias l="lazygit"
alias vim="nvim"
alias ls="ls --color -a"

function fish_user_key_bindings
  bind \cr 'fzf_select_history (commandline -b)'
  bind \cf fzf_select_ghq_repository
  bind \cp 'fzf_select_file_to_edit'
  bind \co 'fzf_select_cd'
  bind \cl clear
end

if test -e /etc/os-release
    # Linux
    alias pbcopy="xsel --clipboard --input"
    alias pbpaste-"xsel --clipboard --output"
end