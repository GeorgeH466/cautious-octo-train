#!/usr/bin/env bash
# traceroute-visual.sh — Visual traceroute with per-hop geolocation
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
  cyber_banner "TRACEROUTE-VISUAL" "Visual traceroute with per-hop geolocation"
  cat <<USAGE
  USAGE: traceroute-visual.sh <host>
  Uses mtr if available; otherwise traceroute + ip-api geolocation per hop.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(curl:curl); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "TRACEROUTE-VISUAL" "Visual traceroute with per-hop geolocation"
  :
  log_msg "START args: $*"

  local host="${1:-1.1.1.1}"; section "ROUTE TO $host"
  if have mtr; then mtr --report --report-cycles 3 "$host" | tee -a "$LOG_FILE"
  elif have traceroute; then traceroute -n -w 2 -q 1 "$host" 2>/dev/null | tail -n +2 | while read -r hop ip rest; do
      local geo=""; [[ "$ip" =~ ^[0-9] ]] && geo="$(curl -fsS --max-time 3 "http://ip-api.com/line/$ip?fields=country,city,isp" 2>/dev/null | tr '\n' ' ')"
      printf '  %s%2s ──▸ %-16s%s %s %s\n' "$C_PRIMARY" "$hop" "$ip" "$C_RESET" "$rest" "$geo"; done | tee -a "$LOG_FILE"
  else die "Install mtr or traceroute"; fi; ok "Trace complete."
  log_msg "DONE rc=$?"
}
main "$@"
