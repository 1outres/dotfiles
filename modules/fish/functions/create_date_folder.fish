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