#!/usr/bin/env bash
# wifi-scan.sh — Wireless network scanner with signal strength
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
  cyber_banner "WIFI-SCAN" "Wireless network scanner with signal strength"
  cat <<USAGE
  USAGE: wifi-scan.sh [interface]
  Lists nearby APs with SSID, BSSID, channel, encryption and signal bars.
  Uses nmcli when available, falls back to iw scan.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(iw:iw); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "WIFI-SCAN" "Wireless network scanner with signal strength"
  :
  log_msg "START args: $*"

  local iface="${1:-$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2; exit}')}"
  [[ -z "$iface" ]] && die "No wireless interface found."
  section "WIRELESS SCAN"; kv "Interface" "$iface"
  if have nmcli; then nmcli -f SSID,BSSID,CHAN,SIGNAL,SECURITY dev wifi list --rescan yes 2>/dev/null | tee -a "$LOG_FILE"
  else sudo iw dev "$iface" scan 2>/dev/null | awk '/BSS/{mac=$2} /SSID:/{ssid=$2} /signal:/{sig=$2} /primary channel:/{printf "  %-28s %s ch:%-3s %s dBm\n", ssid, mac, $4, sig}' | tee -a "$LOG_FILE"; fi
  ok "Wireless scan complete."
  log_msg "DONE rc=$?"
}
main "$@"
