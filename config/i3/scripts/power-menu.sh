#!/usr/bin/env bash
# power-menu.sh — rofi session/power menu
set -uo pipefail
CHOICE="$(printf '⏻ Power Off\n↺ Reboot\n⏾ Suspend\n▣ Lock\n⎋ Exit i3\n✖ Cancel' | rofi -dmenu -p '◢ POWER' -theme ~/.config/rofi/config.rasi)" || exit 0
case "$CHOICE" in
  *Power*) systemctl poweroff;;
  *Reboot*) systemctl reboot;;
  *Suspend*) systemctl suspend;;
  *Lock*) lock-screen;;
  *Exit*) i3-msg exit;;
esac
