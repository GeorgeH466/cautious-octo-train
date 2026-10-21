#!/usr/bin/env bash
# recon-dashboard.sh — Reconnaissance — target info | scans | OSINT | notes
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../lib" "$HOME/.cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
[[ -n "${LIB:-}" ]] && { source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; }
[[ "${1:-}" == "--help" ]] && { cyber_banner "RECON DASHBOARD" "Reconnaissance — target info | scans | OSINT | notes"; echo "  Usage: recon-dashboard.sh — creates/attaches tmux session 'cyberdeck-recon'. Inside tmux already? It switches client."; exit 0; }
command -v tmux >/dev/null || { echo "tmux required: sudo pacman -S tmux" >&2; exit 1; }
SESS="cyberdeck-recon"; BIN="$HOME/.cyberdeck/bin"
run() { tmux send-keys -t "$SESS:$1.$2" "$3" C-m; }
attach() { if [[ -n "${TMUX:-}" ]]; then tmux switch-client -t "$SESS"; else exec tmux attach -t "$SESS"; fi; }
tmux has-session -t "$SESS" 2>/dev/null && { echo "▸ Attaching to existing $SESS session…"; attach; }
cyber_banner "RECON DASHBOARD" "Reconnaissance — target info | scans | OSINT | notes"; log_msg "dashboard $SESS created"

TARGET="${2:-}"
tmux new-session -d -s "$SESS" -n "◢ RECON"
tmux split-window -h -t "$SESS:0"; tmux split-window -v -t "$SESS:0.0"; tmux split-window -v -t "$SESS:0.2"
run 0 0 "echo '◢ TARGET CONSOLE — osint-lookup <t> · whois-lookup <t> · dns-enum <t>' ${TARGET:+; osint-lookup $TARGET}"
run 0 1 "echo '◢ SCAN RESULTS — results land in ~/.cyberdeck/reports/'; ls -lt ~/.cyberdeck/reports | head"
run 0 2 "echo '◢ OSINT — subdomain-enum · web-tech-detect · ssl-analyze · wayback-fetch'"
run 0 3 "mkdir -p ~/.cyberdeck/notes; ${EDITOR:-vim} ~/.cyberdeck/targets/recon-notes.md"
tmux select-pane -t "$SESS:0.0"; attach
