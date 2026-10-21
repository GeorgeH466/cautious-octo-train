#!/usr/bin/env bash
# bandwidth-test.sh — Internet & LAN bandwidth testing
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
  cyber_banner "BANDWIDTH-TEST" "Internet & LAN bandwidth testing"
  cat <<USAGE
  USAGE: bandwidth-test.sh [server]
  No args: internet speed via speedtest-cli / cloudflare fallback download test.
  With a host: iperf3 to that server (needs iperf3 -s running there).
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(curl:curl); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "BANDWIDTH-TEST" "Internet & LAN bandwidth testing"
  :
  log_msg "START args: $*"

  if [[ -n "${1:-}" ]]; then check_deps iperf3:iperf3 || exit 1; iperf3 -c "$1" | tee -a "$LOG_FILE"
  elif have speedtest; then speedtest --simple | tee -a "$LOG_FILE"
  elif have speedtest-cli; then speedtest-cli --simple | tee -a "$LOG_FILE"
  else info "speedtest not found — timing a 25 MB download from Cloudflare…"
    local t0 t1; t0=$(date +%s.%N); curl -fsS -o /dev/null --max-time 60 "https://speed.cloudflare.com/__down?bytes=25000000"; t1=$(date +%s.%N)
    awk -v a="$t0" -v b="$t1" 'BEGIN{s=b-a; printf "  Download ≈ %.1f Mbit/s (25 MB in %.1fs)\n", (25*8)/s, s}' | tee -a "$LOG_FILE"; fi
  ok "Bandwidth test complete."
  log_msg "DONE rc=$?"
}
main "$@"
