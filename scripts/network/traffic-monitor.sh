#!/usr/bin/env bash
# traffic-monitor.sh — Real-time traffic monitoring (iftop / nethogs / ss)
# Cyberdeck-BlackArch | MIT | Part of scripts/network/
set -uo pipefail
# ── locate shared libraries ──────────────────────────────────────────────
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do
  [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }
done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh";
else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi

usage() {
  cyber_banner "TRAFFIC-MONITOR" "Real-time traffic monitoring (iftop / nethogs / ss)"
  cat <<USAGE
  USAGE: traffic-monitor.sh [iface|procs|conns]
  iface name → iftop bandwidth view | procs → nethogs per-process | conns → live ss table (default)
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# no external deps beyond coreutils
main() {
  cyber_banner "TRAFFIC-MONITOR" "Real-time traffic monitoring (iftop / nethogs / ss)"
  :
  log_msg "START args: $*"

  local mode="${1:-conns}"
  case "$mode" in
    procs) have nethogs && sudo nethogs || { warn "nethogs missing (sudo pacman -S nethogs) — showing connections"; mode=conns; } ;;
    conns) watch -n 1 --color "echo '── ACTIVE CONNECTIONS ──'; ss -tunap 2>/dev/null | head -40" ;;
    *) if have iftop; then sudo iftop -i "$mode"; else warn "iftop missing — falling back to live connection table"; watch -n 1 "ss -tunap | head -40"; fi ;;
  esac
  log_msg "DONE rc=$?"
}
main "$@"
