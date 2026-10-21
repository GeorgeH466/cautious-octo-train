#!/usr/bin/env bash
# vpn-manager.sh — OpenVPN / WireGuard connection manager
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
  cyber_banner "VPN-MANAGER" "OpenVPN / WireGuard connection manager"
  cat <<USAGE
  USAGE: vpn-manager.sh <status|up [name]|down [name]|list|ip>
  WireGuard configs: /etc/wireguard/*.conf   OpenVPN: ~/.cyberdeck/vpn/*.ovpn
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# no external deps beyond coreutils
main() {
  cyber_banner "VPN-MANAGER" "OpenVPN / WireGuard connection manager"
  :
  log_msg "START args: $*"

  local action="${1:-status}" name="${2:-}"
  case "$action" in
    list) section "WIREGUARD"; ls /etc/wireguard/*.conf 2>/dev/null | xargs -rn1 basename | sed 's/.conf//;s/^/    wg: /'; section "OPENVPN"; mkdir -p "$CYBERDECK_HOME/vpn"; ls "$CYBERDECK_HOME/vpn"/*.ovpn 2>/dev/null | xargs -rn1 basename | sed 's/^/    ovpn: /'; ls /etc/wireguard/*.conf "$CYBERDECK_HOME/vpn"/*.ovpn >/dev/null 2>&1 || warn "No VPN configs found yet." ;;
    status) ip -brief link show type wireguard 2>/dev/null | sed 's/^/  wg: /'; pgrep -a openvpn | sed 's/^/  ovpn: /'; kv "Public IP" "$(public_ip)" ;;
    ip) kv "Public IP" "$(public_ip)"; curl -fsS --max-time 5 "https://ipinfo.io/$(public_ip)/json" 2>/dev/null | grep -E 'city|region|country|org' | sed 's/^/    /' ;;
    up) [[ -z "$name" ]] && die "Usage: vpn-manager up <name>"; if [[ -f "/etc/wireguard/$name.conf" ]]; then sudo wg-quick up "$name"; elif [[ -f "$CYBERDECK_HOME/vpn/$name.ovpn" ]]; then sudo openvpn --config "$CYBERDECK_HOME/vpn/$name.ovpn" --daemon --log "$CYBERDECK_LOG_DIR/openvpn.log"; else die "Config '$name' not found (try: vpn-manager list)"; fi; sleep 2; ok "Up. Public IP: $(public_ip)" ;;
    down) for i in $(ip -brief link show type wireguard 2>/dev/null|awk '{print $1}'); do sudo wg-quick down "$i"; done; sudo pkill openvpn 2>/dev/null; ok "VPN down. Public IP: $(public_ip)" ;;
    *) die "Usage: vpn-manager status|up|down|list|ip [name]" ;;
  esac; log_msg "vpn $action $name"
  log_msg "DONE rc=$?"
}
main "$@"
