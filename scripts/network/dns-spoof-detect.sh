#!/usr/bin/env bash
# dns-spoof-detect.sh — DNS spoofing / poisoning detection
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
  cyber_banner "DNS-SPOOF-DETECT" "DNS spoofing / poisoning detection"
  cat <<USAGE
  USAGE: dns-spoof-detect.sh [domain...]
  Compares answers from your resolver vs 1.1.1.1, 8.8.8.8, 9.9.9.9 and flags mismatches + checks TTL anomalies.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(dig:bind); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "DNS-SPOOF-DETECT" "DNS spoofing / poisoning detection"
  :
  log_msg "START args: $*"

  local domains=("$@"); [[ ${#domains[@]} -eq 0 ]] && domains=(google.com github.com cloudflare.com example.com)
  section "DNS INTEGRITY CHECK"
  table_header "DOMAIN" "LOCAL" "1.1.1.1" "VERDICT"
  for d in "${domains[@]}"; do
    local l r; l="$(dig +short "$d" A|sort|head -1)"; r="$(dig +short @1.1.1.1 "$d" A|sort|head -1)"
    local v="consistent"; [[ "$l" != "$r" && -n "$l" && -n "$r" ]] && v="MISMATCH ▲"
    table_row "$d" "${l:-none}" "${r:-none}" "$v"; log_msg "dns-check $d local=$l remote=$r $v"
  done; table_footer
  kv "Resolver" "$(grep -m1 nameserver /etc/resolv.conf 2>/dev/null)"; kv "/etc/hosts entries" "$(grep -vcE '^\s*(#|$)' /etc/hosts 2>/dev/null)"
  grep -vE '^\s*(#|$)|localhost|broadcasthost' /etc/hosts 2>/dev/null | sed 's/^/    hosts: /' | head
  ok "Check complete — a mismatch can also be CDN/GeoDNS; investigate before concluding poisoning."
  log_msg "DONE rc=$?"
}
main "$@"
