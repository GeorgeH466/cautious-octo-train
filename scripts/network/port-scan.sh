#!/usr/bin/env bash
# port-scan.sh — Quick/full port scan with service detection
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
  cyber_banner "PORT-SCAN" "Quick/full port scan with service detection"
  cat <<USAGE
  USAGE: port-scan.sh <target> [ports]
  ports: 'top' (default 1000), 'all', or explicit list e.g. 22,80,443
  Example: port-scan.sh example.com 1-1024
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(nmap:nmap); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "PORT-SCAN" "Quick/full port scan with service detection"
  legal_warning
  log_msg "START args: $*"

  local target="${1:-}"; [[ -z "$target" ]] && { read -rp "  Target: " target </dev/tty || die "Target required"; }
  local ports="${2:-top}" parg="--top-ports 1000"; [[ "$ports" == "all" ]] && parg="-p-"; [[ "$ports" != "top" && "$ports" != "all" ]] && parg="-p $ports"
  section "PORT SCAN"; kv "Target" "$target"; kv "Ports" "$ports"
  # shellcheck disable=SC2086
  nmap -sV -sC -T4 $parg --open "$target" | tee -a "$LOG_FILE"; ok "Port scan complete."
  log_msg "DONE rc=$?"
}
main "$@"
