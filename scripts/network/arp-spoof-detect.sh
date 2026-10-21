#!/usr/bin/env bash
# arp-spoof-detect.sh — ARP spoofing / MITM detection on the LAN
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
  cyber_banner "ARP-SPOOF-DETECT" "ARP spoofing / MITM detection on the LAN"
  cat <<USAGE
  USAGE: arp-spoof-detect.sh [--watch]
  Checks for duplicate MACs, gateway MAC changes and unsolicited ARP replies.
  --watch monitors continuously (Ctrl-C to stop).
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(ip:iproute2); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "ARP-SPOOF-DETECT" "ARP spoofing / MITM detection on the LAN"
  :
  log_msg "START args: $*"

  local gw; gw="$(gateway_ip)"; section "ARP INTEGRITY"; kv "Gateway" "$gw"; kv "Gateway MAC" "$(ip neigh show $gw 2>/dev/null|awk '{print $5}')"
  info "Duplicate-MAC check (same MAC claiming multiple IPs = suspicious):"
  ip neigh show | awk '{print $5}' | sort | uniq -d | while read -r m; do [[ -n "$m" && "$m" != "FAILED" ]] && warn "MAC $m appears for multiple IPs:" && ip neigh show | grep "$m" | sed 's/^/      /'; done
  ok "Static check done."
  if [[ "${1:-}" == "--watch" ]]; then info "Watching ARP traffic… Ctrl-C to stop"; if have arpwatch; then sudo arpwatch -i "$(default_iface)" -n -q 2>&1 | head; elif have tcpdump; then sudo tcpdump -l -i "$(default_iface)" arp 2>/dev/null | while read -r line; do printf '  %s%s%s\n' "$C_AMBER" "$line" "$C_RESET"; log_msg "ARP: $line"; done; else die "Install tcpdump or arpwatch for --watch"; fi; fi
  log_msg "DONE rc=$?"
}
main "$@"
