#!/usr/bin/env bash
# network-ops.sh — Network operations — capture | traffic | connections | IDS alerts
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../lib" "$HOME/.cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
[[ -n "${LIB:-}" ]] && { source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; }
[[ "${1:-}" == "--help" ]] && { cyber_banner "NETWORK OPS" "Network operations — capture | traffic | connections | IDS alerts"; echo "  Usage: network-ops.sh — creates/attaches tmux session 'cyberdeck-net'. Inside tmux already? It switches client."; exit 0; }
command -v tmux >/dev/null || { echo "tmux required: sudo pacman -S tmux" >&2; exit 1; }
SESS="cyberdeck-net"; BIN="$HOME/.cyberdeck/bin"
run() { tmux send-keys -t "$SESS:$1.$2" "$3" C-m; }
attach() { if [[ -n "${TMUX:-}" ]]; then tmux switch-client -t "$SESS"; else exec tmux attach -t "$SESS"; fi; }
tmux has-session -t "$SESS" 2>/dev/null && { echo "▸ Attaching to existing $SESS session…"; attach; }
cyber_banner "NETWORK OPS" "Network operations — capture | traffic | connections | IDS alerts"; log_msg "dashboard $SESS created"

tmux new-session -d -s "$SESS" -n "◢ NETOPS"
tmux split-window -h -t "$SESS:0"; tmux split-window -v -t "$SESS:0.0"; tmux split-window -v -t "$SESS:0.2"
IFACE="$(ip route show default | awk 'NR==1{print $5}')"
run 0 0 "echo '◢ PACKET CAPTURE — packet-capture $IFACE'; sudo tcpdump -i $IFACE -nn -l 2>/dev/null | head -200"
run 0 1 "traffic-monitor"
run 0 2 "connection-monitor --watch"
run 0 3 "arp-spoof-detect; echo; dns-spoof-detect"
tmux new-window -t "$SESS:1" -n "SCAN"
run 1 0 "echo '◢ SCAN CONSOLE — net-discover · net-scan <target> · wifi-scan'"
tmux select-window -t "$SESS:0"; attach
