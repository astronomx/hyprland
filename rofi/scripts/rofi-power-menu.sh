#! /bin/sh

chosen=$(printf "Lock\nRestart\nPower Off" | rofi -dmenu -i)

case "$chosen" in
"Lock") hyprlock ;;
"Restart") reboot ;;
"Power Off") poweroff ;;
*) exit 1 ;;
esac
