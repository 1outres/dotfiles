# Hyprland keeps the built-in panel running when the lid shuts, so a docked
# laptop drives a screen nobody can see. Turn that panel off while the lid is
# closed, but only when another monitor is attached: closing the lid on a bare
# laptop would otherwise leave the session with no output at all.
#
# Called as "closed" or "opened" from the lid switch, and as "sync" at startup
# to apply whichever state the lid is already in.

internal=$(hyprctl monitors all -j | jq -r '[.[] | select(.name | startswith("eDP"))] | .[0].name // empty')

if [ -z "$internal" ]; then
  exit 0
fi

action=${1:-sync}

if [ "$action" = "sync" ]; then
  if grep -q closed /proc/acpi/button/lid/*/state 2>/dev/null; then
    action=closed
  else
    action=opened
  fi
fi

externals=$(hyprctl monitors -j | jq -r --arg internal "$internal" '[.[] | select(.name != $internal)] | length')

if [ "$action" = "closed" ] && [ "$externals" -gt 0 ]; then
  hyprctl keyword monitor "$internal, disable"
else
  hyprctl keyword monitor "$internal, preferred, auto, 1"
fi
