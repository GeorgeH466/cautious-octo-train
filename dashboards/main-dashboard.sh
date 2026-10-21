#!/usr/bin/env bash
# main-dashboard.sh — Primary cyberdeck dashboard — system stats | network | logs | launcher
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../lib" "$HOME/.cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
[[ -n "${LIB:-}" ]] && { source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; }
[[ "${1:-}" == "--help" ]] && { cyber_banner "MAIN DASHBOARD" "Primary cyberdeck dashboard — system stats | network | logs | launcher"; echo "  Usage: main-dashboard.sh — creates/attaches tmux session 'cyberdeck-main'. Inside tmux already? It switches client."; exit 0; }
command -v tmux >/dev/null || { echo "tmux required: sudo pacman -S tmux" >&2; exit 1; }
SESS="cyberdeck-main"; BIN="$HOME/.cyberdeck/bin"
run() { tmux send-keys -t "$SESS:$1.$2" "$3" C-m; }
attach() { if [[ -n "${TMUX:-}" ]]; then tmux switch-client -t "$SESS"; else exec tmux attach -t "$SESS"; fi; }
tmux has-session -t "$SESS" 2>/dev/null && { echo "▸ Attaching to existing $SESS session…"; attach; }
cyber_banner "MAIN DASHBOARD" "Primary cyberdeck dashboard — system stats | network | logs | launcher"; log_msg "dashboard $SESS created"

tmux new-session -d -s "$SESS" -n "◢ MAIN"
tmux split-window -h -t "$SESS:0"; tmux split-window -v -t "$SESS:0.0"; tmux split-window -v -t "$SESS:0.2"
run 0 0 "status-board --watch 5"
run 0 1 "resource-monitor"
run 0 2 "log-viewer cyberdeck --follow"
run 0 3 "clear; echo '◢ TOOL LAUNCHER — try: toolkit-menu · cheatsheet · cyberdeck tools'; neofetch 2>/dev/null | head -20"
tmux new-window -t "$SESS:1" -n "SHELL"
run 1 0 "boot-splash --fast"
tmux select-window -t "$SESS:0"; tmux select-pane -t "$SESS:0.3"
attach
