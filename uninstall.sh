#!/usr/bin/env bash
# uninstall.sh — Cleanly remove Cyberdeck-BlackArch (restores config backups)
# Usage: ./uninstall.sh [--purge]   --purge also deletes ~/.cyberdeck data/logs
set -uo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DECK="$HOME/.cyberdeck"
source "$REPO_DIR/lib/colors.sh" 2>/dev/null || true
source "$REPO_DIR/lib/ui.sh" 2>/dev/null || { ok(){ echo "[✔] $*"; }; warn(){ echo "[▲] $*"; }; info(){ echo "[◆] $*"; }; cyber_banner(){ echo "◢ $1"; }; section(){ echo "┌─[ $1 ]"; }; confirm(){ read -rp "$1 [y/N] " r; [[ "$r" =~ ^[Yy] ]]; }; }
[[ "${1:-}" == "--help" ]] && { grep -E '^#' "$0" | head -6 | sed 's/^# \{0,1\}//'; exit 0; }

cyber_banner "UNINSTALLER" "CYBERDECK REMOVAL SEQUENCE"
confirm "Remove Cyberdeck configs/scripts from this system?" || { info "Aborted — deck remains online."; exit 0; }

section "STOPPING DECK PROCESSES"
pkill -f cyberdeck-netdaemon 2>/dev/null; pkill polybar 2>/dev/null; pkill conky 2>/dev/null; pkill picom 2>/dev/null
tmux ls 2>/dev/null | grep -o '^cyberdeck-[^:]*' | while read -r s; do tmux kill-session -t "$s" 2>/dev/null; done
ok "Processes stopped."

section "RESTORING CONFIG BACKUPS"
LATEST="$(ls -dt "$DECK"/backups/config-backup-* 2>/dev/null | head -1)"
if [[ -n "$LATEST" && -d "$LATEST$HOME" ]]; then
  info "Restoring from $LATEST"
  (cd "$LATEST" && find . -type f | while read -r f; do mkdir -p "$(dirname "/${f#./}")"; cp -a "$f" "/${f#./}"; done)
  ok "Original configs restored."
else
  warn "No backup found — removing cyberdeck config dirs instead."
  for d in i3 polybar picom alacritty rofi dunst neofetch ranger conky cava; do rm -rf "$HOME/.config/$d"; done
  rm -f "$HOME/.tmux.conf" "$HOME/.zshrc" "$HOME/.p10k.zsh" "$HOME/.vimrc"
fi

section "REMOVING COMMANDS"
rm -f "$HOME/.local/bin/cyberdeck"
for d in "$DECK/bin" "$DECK/lib" "$DECK/scripts" "$DECK/dashboards" "$DECK/tui" "$DECK/wallpapers" "$DECK/sounds" "$DECK/venv"; do rm -rf "$d"; done
ok "Deck binaries/scripts removed (system packages installed via pacman are kept — remove with pacman -Rns if desired)."

if [[ "${1:-}" == "--purge" ]]; then
  confirm "PURGE all ~/.cyberdeck data (logs, captures, notes, reports)? This is irreversible." && { rm -rf "$DECK"; ok "~/.cyberdeck purged."; }
else
  info "Kept your data in $DECK (logs/captures/notes/reports). Full wipe: ./uninstall.sh --purge"
fi
ok "◢ Cyberdeck removed. Log out/in to return to your previous session."
