#!/usr/bin/env bash
# defense-dashboard.sh — Defense monitoring — IDS alerts | connections | processes | integrity
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../lib" "$HOME/.cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
[[ -n "${LIB:-}" ]] && { source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; }
[[ "${1:-}" == "--help" ]] && { cyber_banner "DEFENSE DASHBOARD" "Defense monitoring — IDS alerts | connections | processes | integrity"; echo "  Usage: defense-dashboard.sh — creates/attaches tmux session 'cyberdeck-defense'. Inside tmux already? It switches client."; exit 0; }
command -v tmux >/dev/null || { echo "tmux required: sudo pacman -S tmux" >&2; exit 1; }
SESS="cyberdeck-defense"; BIN="$HOME/.cyberdeck/bin"
run() { tmux send-keys -t "$SESS:$1.$2" "$3" C-m; }
attach() { if [[ -n "${TMUX:-}" ]]; then tmux switch-client -t "$SESS"; else exec tmux attach -t "$SESS"; fi; }
tmux has-session -t "$SESS" 2>/dev/null && { echo "▸ Attaching to existing $SESS session…"; attach; }
cyber_banner "DEFENSE DASHBOARD" "Defense monitoring — IDS alerts | connections | processes | integrity"; log_msg "dashboard $SESS created"

tmux new-session -d -s "$SESS" -n "◢ DEFENSE"
tmux split-window -h -t "$SESS:0"; tmux split-window -v -t "$SESS:0.0"; tmux split-window -v -t "$SESS:0.2"
run 0 0 "log-viewer auth --follow"
run 0 1 "connection-monitor --watch"
run 0 2 "watch -n 5 'process-monitor'"
run 0 3 "system-harden; echo; integrity-check verify 2>/dev/null | tail -5; echo '─ threat feed: status-board'"
tmux new-window -t "$SESS:1" -n "LOGS"; run 1 0 "journalctl -f -p warning"
tmux select-window -t "$SESS:0"; attach
