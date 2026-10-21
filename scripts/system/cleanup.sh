#!/usr/bin/env bash
# cleanup.sh — System cleanup — pacman cache, journals, temp, trash, orphans
# Cyberdeck-BlackArch | MIT | Part of scripts/system/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "CLEANUP" "System cleanup — pacman cache, journals, temp, trash, orphans"; cat <<USAGE
  USAGE: cleanup.sh [--dry-run]
  Frees space safely: keeps 3 pkg versions, vacuums journal to 200M, clears temp & thumbnails.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "CLEANUP" "System cleanup — pacman cache, journals, temp, trash, orphans"; :; log_msg "START args: $*"

  local dry=0; [[ "${1:-}" == "--dry-run" ]] && dry=1
  run() { if [[ $dry -eq 1 ]]; then info "[dry-run] $*"; else eval "$*"; fi; }
  section "BEFORE"; df -h / | tail -1 | sed 's/^/  /'
  info "Pacman cache: $(du -sh /var/cache/pacman/pkg 2>/dev/null|cut -f1)"; have paccache && run "sudo paccache -r" || run "sudo pacman -Sc --noconfirm"
  info "Orphan packages:"; pacman -Qtdq 2>/dev/null | sed 's/^/    /' | head; [[ -n "$(pacman -Qtdq 2>/dev/null)" ]] && confirm "Remove orphans?" && run "pacman -Qtdq | sudo pacman -Rns -"
  run "sudo journalctl --vacuum-size=200M"
  run "rm -rf ~/.cache/thumbnails/* ~/.local/share/Trash/* 2>/dev/null; find /tmp -user $USER -mtime +7 -delete 2>/dev/null"
  section "AFTER"; df -h / | tail -1 | sed 's/^/  /'; ok "Cleanup complete."; log_msg "cleanup dry=$dry"
  log_msg "DONE"; }
main "$@"
