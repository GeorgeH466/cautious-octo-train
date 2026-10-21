#!/usr/bin/env bash
# dns-enum.sh — DNS enumeration — records, zone transfer, brute subdomains
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
  cyber_banner "DNS-ENUM" "DNS enumeration — records, zone transfer, brute subdomains"
  cat <<USAGE
  USAGE: dns-enum.sh <domain> [wordlist]
  Queries A/AAAA/MX/NS/TXT/SOA/CAA, tries AXFR, optionally brute-forces subdomains.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(dig:bind); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "DNS-ENUM" "DNS enumeration — records, zone transfer, brute subdomains"
  legal_warning
  log_msg "START args: $*"

  local domain="${1:-}"; [[ -z "$domain" ]] && { read -rp "  Domain: " domain </dev/tty || die "Domain required"; }
  local out; out="$(outdir dns-enum)"
  section "DNS RECORDS — $domain"
  for t in A AAAA MX NS TXT SOA CAA SRV; do printf '\n  %s── %s ──%s\n' "$C_PRIMARY" "$t" "$C_RESET"; dig +short "$domain" "$t" | sed 's/^/    /' | tee -a "$out/records.txt"; done
  section "ZONE TRANSFER (AXFR) TEST"
  for ns in $(dig +short NS "$domain"); do info "Trying AXFR @ $ns"; dig AXFR "$domain" "@$ns" +time=5 2>/dev/null | head -20 | sed 's/^/    /'; done
  if [[ -n "${2:-}" && -f "$2" ]]; then section "SUBDOMAIN BRUTE ($2)"; while read -r sub; do ip=$(dig +short "$sub.$domain" | head -1); [[ -n "$ip" ]] && printf '    %s%s.%s → %s%s\n' "$C_GREEN" "$sub" "$domain" "$ip" "$C_RESET" | tee -a "$out/subdomains.txt"; done <"$2"; fi
  ok "Saved to $out"
  log_msg "DONE rc=$?"
}
main "$@"
