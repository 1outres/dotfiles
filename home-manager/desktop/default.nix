{ vars, ... }:
{
  imports = [
    ./hyprland
    ./waybar
    ./swaylock
    ./cursor.nix
    ./grimshot
  ] ++ (if (vars.enable-swayidle or true) then [ ./swayidle ] else []);
}
