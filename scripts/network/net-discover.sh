#!/usr/bin/env bash
# net-discover.sh — ARP-based live host discovery
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
  cyber_banner "NET-DISCOVER" "ARP-based live host discovery"
  cat <<USAGE
  USAGE: net-discover.sh [subnet]
  Discovers live hosts via ARP (arp-scan if present, else nmap -sn + arp table).
  Example: net-discover.sh 192.168.1.0/24
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(ip:iproute2); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "NET-DISCOVER" "ARP-based live host discovery"
  :
  log_msg "START args: $*"

  local net="${1:-$(local_subnet)}" iface; iface="$(default_iface)"
  section "HOST DISCOVERY"; kv "Subnet" "$net"; kv "Interface" "$iface"
  table_header "IP ADDRESS" "MAC ADDRESS" "HOSTNAME" "STATUS"
  if have arp-scan; then sudo arp-scan --interface="$iface" "$net" 2>/dev/null | grep -E '^[0-9]' | while read -r ip mac _; do table_row "$ip" "$mac" "$(getent hosts $ip | awk '{print $2}')" "online"; done
  elif have nmap; then nmap -sn "$net" -oG - 2>/dev/null | awk '/Up$/{print $2}' | while read -r ip; do table_row "$ip" "$(ip neigh show $ip 2>/dev/null|awk '{print $5}')" "$(getent hosts $ip|awk '{print $2}')" "online"; done
  else ping -c1 -b "$(echo $net|cut -d/ -f1)" >/dev/null 2>&1; ip neigh show | awk '{print $1, $5}' | while read -r ip mac; do table_row "$ip" "$mac" "-" "seen"; done; fi
  table_footer; ok "Discovery complete."
  log_msg "DONE rc=$?"
}
main "$@"
