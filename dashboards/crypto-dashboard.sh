#!/usr/bin/env bash
# crypto-dashboard.sh — Cryptography workspace — encryption | hashing | keys | steganography
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../lib" "$HOME/.cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
[[ -n "${LIB:-}" ]] && { source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; }
[[ "${1:-}" == "--help" ]] && { cyber_banner "CRYPTO DASHBOARD" "Cryptography workspace — encryption | hashing | keys | steganography"; echo "  Usage: crypto-dashboard.sh — creates/attaches tmux session 'cyberdeck-crypto'. Inside tmux already? It switches client."; exit 0; }
command -v tmux >/dev/null || { echo "tmux required: sudo pacman -S tmux" >&2; exit 1; }
SESS="cyberdeck-crypto"; BIN="$HOME/.cyberdeck/bin"
run() { tmux send-keys -t "$SESS:$1.$2" "$3" C-m; }
attach() { if [[ -n "${TMUX:-}" ]]; then tmux switch-client -t "$SESS"; else exec tmux attach -t "$SESS"; fi; }
tmux has-session -t "$SESS" 2>/dev/null && { echo "▸ Attaching to existing $SESS session…"; attach; }
cyber_banner "CRYPTO DASHBOARD" "Cryptography workspace — encryption | hashing | keys | steganography"; log_msg "dashboard $SESS created"

tmux new-session -d -s "$SESS" -n "◢ CRYPTO"
tmux split-window -h -t "$SESS:0"; tmux split-window -v -t "$SESS:0.0"; tmux split-window -v -t "$SESS:0.2"
run 0 0 "echo '◢ ENCRYPT — encrypt-file <f> · decrypt-file <f.age>'; ls -la ~/ | head"
run 0 1 "echo '◢ HASH — hash-file <f> · hash-crack <hashes> <list>'; password-gen 24 3"
run 0 2 "key-manager list"
run 0 3 "echo '◢ STEGO — steganography info <img> · hide/extract'; hex-dump-visual /bin/true 2>/dev/null | head -12"
tmux select-pane -t "$SESS:0.0"; attach
