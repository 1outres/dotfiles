alias l="lazygit"
alias vim="nvim"
alias ls="ls --color -a"

function fish_user_key_bindings
end

if test -e /etc/os-release
    # Linux
    alias pbcopy="xsel --clipboard --input"
    alias pbpaste-"xsel --clipboard --output"
end