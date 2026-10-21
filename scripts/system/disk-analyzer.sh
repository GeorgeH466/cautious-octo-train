#!/usr/bin/env bash
# disk-analyzer.sh — Disk usage analyzer — big files, growth, SMART hints
# Cyberdeck-BlackArch | MIT | Part of scripts/system/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "DISK-ANALYZER" "Disk usage analyzer — big files, growth, SMART hints"; cat <<USAGE
  USAGE: disk-analyzer.sh [path] [--top N]
  Uses ncdu when interactive & available; otherwise du summaries + largest files.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "DISK-ANALYZER" "Disk usage analyzer — big files, growth, SMART hints"; :; log_msg "START args: $*"

  local path="${1:-$HOME}"; [[ "$path" == "--top" ]] && path="$HOME"
  section "FILESYSTEMS"; df -hT 2>/dev/null | sed 's/^/  /'
  if [[ -t 0 ]] && have ncdu; then info "ncdu available — press Enter for interactive browser, Ctrl-C for summary"; read -r _ </dev/tty && ncdu "$path" && exit 0; fi
  section "TOP DIRECTORIES IN $path"; du -h -d1 "$path" 2>/dev/null | sort -hr | head -15 | sed 's/^/  /'
  section "LARGEST FILES"; find "$path" -type f -printf '%s %p\n' 2>/dev/null | sort -rn | head -12 | awk '{printf "  %8.1f MB  %s\n", $1/1048576, substr($0,index($0,$2))}'
  section "PACMAN CACHE"; du -sh /var/cache/pacman/pkg 2>/dev/null | sed 's/^/  /'; info "Reclaim: sudo paccache -r  (keeps 3 versions)"
  log_msg "DONE"; }
main "$@"
