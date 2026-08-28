# Walk the windows of the focused application, the way Cmd+` does on macOS.
# Hyprland has no dispatcher for this: cyclenext walks every window regardless
# of which application owns it.
#
# Windows are ordered by address so the cycle stays stable between runs.

direction=${1:-next}

current=$(hyprctl activewindow -j)
class=$(printf '%s' "$current" | jq -r '.class // empty')
address=$(printf '%s' "$current" | jq -r '.address // empty')

if [ -z "$class" ]; then
  exit 0
fi

mapfile -t windows < <(
  hyprctl clients -j |
    jq -r --arg class "$class" \
      '[.[] | select(.class == $class and .workspace.id > 0)] | sort_by(.address) | .[].address'
)

count=${#windows[@]}
if [ "$count" -le 1 ]; then
  exit 0
fi

index=0
for i in "${!windows[@]}"; do
  if [ "${windows[$i]}" = "$address" ]; then
    index=$i
  fi
done

if [ "$direction" = "prev" ]; then
  target=$(((index - 1 + count) % count))
else
  target=$(((index + 1) % count))
fi

hyprctl dispatch focuswindow "address:${windows[$target]}"
