#!/usr/bin/env bash
# wifi-monitor.sh — Enable / disable Wi-Fi monitor mode
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
  cyber_banner "WIFI-MONITOR" "Enable / disable Wi-Fi monitor mode"
  cat <<USAGE
  USAGE: wifi-monitor.sh <start|stop|status> [interface]
  Example: wifi-monitor.sh start wlan0
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(iw:iw ip:iproute2); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "WIFI-MONITOR" "Enable / disable Wi-Fi monitor mode"
  legal_warning
  log_msg "START args: $*"

  local action="${1:-status}" iface="${2:-$(iw dev 2>/dev/null|awk '$1=="Interface"{print $2;exit}')}"
  [[ -z "$iface" ]] && die "No wireless interface."
  case "$action" in
    start) require_root "$@"; if have airmon-ng; then airmon-ng check kill; airmon-ng start "$iface"; else ip link set "$iface" down; iw dev "$iface" set type monitor; ip link set "$iface" up; fi; ok "Monitor mode requested on $iface — verify with: iw dev" ;;
    stop) require_root "$@"; if have airmon-ng; then airmon-ng stop "${iface}mon" 2>/dev/null || airmon-ng stop "$iface"; else ip link set "$iface" down; iw dev "$iface" set type managed; ip link set "$iface" up; fi; systemctl restart NetworkManager 2>/dev/null || true; ok "Managed mode restored." ;;
    status) iw dev "$iface" info 2>/dev/null | grep -E 'Interface|type|channel' | sed 's/^/  /'; ;;
    *) die "Usage: wifi-monitor.sh start|stop|status [iface]" ;;
  esac
  log_msg "DONE rc=$?"
}
main "$@"
