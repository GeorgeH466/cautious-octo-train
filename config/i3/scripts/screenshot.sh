#!/usr/bin/env bash
# screenshot.sh — styled screenshots: selection (default) or full; border + clipboard + notify
set -uo pipefail
DIR="$HOME/Pictures/Screenshots"; mkdir -p "$DIR"
FILE="$DIR/cyberdeck-$(date +%Y%m%d-%H%M%S).png"
if [[ "${1:-}" == "full" ]]; then scrot "$FILE"; else scrot -s -f "$FILE" 2>/dev/null || scrot "$FILE"; fi
# Neon border frame via ImageMagick if available
if command -v convert >/dev/null && [[ -f "$FILE" ]]; then
  PRIM="$(grep -oP 'primary=\K.*' ~/.cyberdeck/current-theme.env 2>/dev/null || echo '#00fff5')"
  convert "$FILE" -bordercolor "$PRIM" -border 2 "$FILE" 2>/dev/null
fi
[[ -f "$FILE" ]] && command -v xclip >/dev/null && xclip -selection clipboard -t image/png -i "$FILE"
notify-send "◢ CAPTURE SAVED" "$FILE (copied to clipboard)"
echo "$FILE" >> ~/.cyberdeck/logs/screenshots.log
