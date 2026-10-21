#!/usr/bin/env bash
# subnet-calc.sh — Subnet calculator (CIDR math, ranges, splits)
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
  cyber_banner "SUBNET-CALC" "Subnet calculator (CIDR math, ranges, splits)"
  cat <<USAGE
  USAGE: subnet-calc.sh <ip/cidr> [new-prefix]
  Prints network, broadcast, host range, wildcard mask; with new-prefix lists subnets.
  Example: subnet-calc.sh 10.0.0.0/8 16
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# no external deps beyond coreutils
main() {
  cyber_banner "SUBNET-CALC" "Subnet calculator (CIDR math, ranges, splits)"
  :
  log_msg "START args: $*"

  local cidr="${1:-$(local_subnet)}"; [[ "$cidr" != */* ]] && cidr="$cidr/24"
  if have ipcalc; then ipcalc "$cidr" ${2:+/} ${2:-} 2>/dev/null | sed 's/^/  /' | tee -a "$LOG_FILE" && exit 0; fi
  if have sipcalc; then sipcalc "$cidr" | sed 's/^/  /' | tee -a "$LOG_FILE" && exit 0; fi
  python3 - "$cidr" "${2:-}" <<PYEOF | tee -a "$LOG_FILE"
import ipaddress,sys
n=ipaddress.ip_network(sys.argv[1],strict=False)
print(f"  Network    {n.network_address}/{n.prefixlen}")
print(f"  Netmask    {n.netmask}   Wildcard {n.hostmask}")
print(f"  Broadcast  {n.broadcast_address}")
hosts=list(n.hosts()); print(f"  Hosts      {hosts[0] if hosts else '-'} – {hosts[-1] if hosts else '-'}  ({len(hosts)} usable)")
if sys.argv[2]:
    print(f"  ── Subnets /{sys.argv[2]} ──")
    for s in n.subnets(new_prefix=int(sys.argv[2])): print(f"    {s}")
PYEOF
  ok "Calculation complete."
  log_msg "DONE rc=$?"
}
main "$@"
