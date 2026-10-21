#!/usr/bin/env bash
# connection-monitor.sh — Active connection monitor with new-connection alerts
# Cyberdeck-BlackArch | MIT | Part of scripts/defense/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "CONNECTION-MONITOR" "Active connection monitor with new-connection alerts"; cat <<USAGE
  USAGE: connection-monitor.sh [--watch] [--resolve]
  Snapshot or live-watch established connections; --watch alerts on NEW remote endpoints.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "CONNECTION-MONITOR" "Active connection monitor with new-connection alerts"; :; log_msg "START args: $*"

  snapshot() { ss -tunp state established 2>/dev/null | tail -n +2 | awk '{print $5}' | sort -u; }
  render() { table_header "LOCAL" "REMOTE" "PROCESS" "STATE"; ss -tunap 2>/dev/null | grep ESTAB | head -30 | while read -r _ _ _ loc rem _ proc; do table_row "$loc" "$rem" "${proc:-?}" "ESTAB"; done; table_footer; }
  render | tee -a "$LOG_FILE"
  if [[ "$*" == *"--watch"* ]]; then local known; known="$(snapshot)"; info "Watching for new endpoints… Ctrl-C stops"
    while true; do sleep 3; local now new; now="$(snapshot)"; new="$(comm -13 <(echo "$known") <(echo "$now"))"; [[ -n "$new" ]] && while read -r e; do warn "NEW connection → $e $( [[ "$*" == *"--resolve"* ]] && getent hosts ${e%:*} )"; log_msg "NEW CONN $e"; have notify-send && notify-send "Cyberdeck ▲" "New connection: $e"; done <<<"$new"; known="$now"; done; fi
  log_msg "DONE"; }
main "$@"
