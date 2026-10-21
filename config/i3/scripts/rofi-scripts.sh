#!/usr/bin/env bash
# rofi-scripts.sh — Super+Shift+d: search & launch any cyberdeck module in a terminal
set -uo pipefail
BASE="$HOME/.cyberdeck/scripts"; [[ -d "$BASE" ]] || BASE="$(cd "$(dirname "$0")/../../scripts" && pwd)"
LIST="$(find "$BASE" -name '*.sh' | sort | while read -r f; do printf '%s ▸ %s\n' "$(basename "$f" .sh)" "$(grep -m1 '^# .*\.sh —' "$f" | sed 's/.*— //')"; done)"
PICK="$(echo "$LIST" | rofi -dmenu -i -p '◢ MODULES' -theme ~/.config/rofi/config.rasi)" || exit 0
NAME="${PICK%% ▸*}"; [[ -z "$NAME" ]] && exit 0
FILE="$(find "$BASE" -name "$NAME.sh" -print -quit)"
exec alacritty -e bash -c "'$FILE' --help; echo; echo '── press Enter to run interactively, Ctrl-C to just read help ──'; read -r _; '$FILE'; exec \$SHELL"
