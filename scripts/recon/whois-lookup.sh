#!/usr/bin/env bash
# whois-lookup.sh — Enhanced whois with clean formatting
# Cyberdeck-BlackArch | MIT | Part of scripts/recon/
set -uo pipefail
# ── locate shared libraries ──────────────────────────────────────────────
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do
  [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }
done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh";
else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi

usage() {
  cyber_banner "WHOIS-LOOKUP" "Enhanced whois with clean formatting"
  cat <<USAGE
  USAGE: whois-lookup.sh <domain|ip>  — key fields only, plus raw saved to reports.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(whois:whois); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "WHOIS-LOOKUP" "Enhanced whois with clean formatting"
  :
  log_msg "START args: $*"

  local t="${1:-}"; [[ -z "$t" ]] && die "Usage: whois-lookup <domain|ip>"
  local out; out="$(outdir whois)"; whois "$t" >"$out/whois.txt" 2>/dev/null
  section "WHOIS — $t"
  grep -iE '^(domain|registrar|creation|created|updated|expir|name server|nserver|org|organisation|country|state|city|dnssec|status|inetnum|netname|descr|CIDR|origin|asn)' "$out/whois.txt" | sed 's/ *: */ :: /' | sort -u | while IFS= read -r l; do kv "${l%% ::*}" "${l#* :: }"; done
  ok "Raw whois: $out/whois.txt"
  log_msg "DONE rc=$?"
}
main "$@"
