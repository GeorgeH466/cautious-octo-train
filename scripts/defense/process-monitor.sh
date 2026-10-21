#!/usr/bin/env bash
# process-monitor.sh — Suspicious process hunter (deleted exes, odd parents, miners)
# Cyberdeck-BlackArch | MIT | Part of scripts/defense/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "PROCESS-MONITOR" "Suspicious process hunter (deleted exes, odd parents, miners)"; cat <<USAGE
  USAGE: process-monitor.sh [--watch [secs]]
  Flags: processes running from /tmp or deleted binaries, no-TTY shells with network, high-CPU unknowns.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "PROCESS-MONITOR" "Suspicious process hunter (deleted exes, odd parents, miners)"; :; log_msg "START args: $*"

  scan_once() {
    section "RUNNING FROM SUSPICIOUS PATHS (/tmp, /dev/shm, deleted)"
    for p in /proc/[0-9]*; do local exe; exe="$(readlink $p/exe 2>/dev/null)"; case "$exe" in /tmp/*|/dev/shm/*|*'(deleted)'*) printf '  %s[▲] pid %-7s %s%s\n' "$C_AMBER" "${p#/proc/}" "$exe" "$C_RESET";; esac; done
    section "TOP CPU"; ps aux --sort=-%cpu | head -8 | sed 's/^/  /'
    section "PROCESSES WITH NETWORK CONNECTIONS"; ss -tunap 2>/dev/null | grep -E 'ESTAB' | head -15 | sed 's/^/  /'
    section "NEWEST PROCESSES"; ps -eo pid,lstart,comm --sort=-lstart 2>/dev/null | head -8 | sed 's/^/  /'
  }
  scan_once | tee -a "$LOG_FILE"
  [[ "${1:-}" == "--watch" ]] && { info "Watching every ${2:-10}s — Ctrl-C to stop"; while true; do sleep "${2:-10}"; scan_once; done; }
  log_msg "DONE"; }
main "$@"
