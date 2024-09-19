swayidle -w timeout 180 'swaylock -f' \
            timeout 300 'hyprctl dispatch dpms off' \
            resume 'hyprctl dispatch dpms on' \
            timeout 600 'systemctl suspend' \
            before-sleep 'swaylock -f' &
