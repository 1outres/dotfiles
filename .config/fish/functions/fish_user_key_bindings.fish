function fish_user_key_bindings
  bind --erase --all --preset
  for mode in default insert visual
    bind -M $mode \cr 'fzf_select_history (commandline -b)'
    bind -M $mode \cf fzf_select_ghq_repository
    bind -M $mode \co fzf_select_file_to_edit
  end
  fish_vi_key_bindings --no-erase
end
