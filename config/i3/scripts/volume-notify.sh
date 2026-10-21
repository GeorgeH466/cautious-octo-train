#!/usr/bin/env bash
# volume-notify.sh — dunst progress-bar volume popup
VOL="$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\d+%' | head -1 | tr -d '%')"
MUTE="$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -o 'yes')"
[[ "$MUTE" == "yes" ]] && notify-send -h string:x-canonical-private-synchronous:vol "♪ MUTED" -h int:value:0 || notify-send -h string:x-canonical-private-synchronous:vol "♪ VOLUME ${VOL}%" -h "int:value:${VOL:-0}"
