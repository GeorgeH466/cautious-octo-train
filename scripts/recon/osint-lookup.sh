#!/usr/bin/env bash
# osint-lookup.sh — OSINT aggregator — IP/domain/user/email in one pass
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
  cyber_banner "OSINT-LOOKUP" "OSINT aggregator — IP/domain/user/email in one pass"
  cat <<USAGE
  USAGE: osint-lookup.sh <target>
  Detects type (IP, domain, email, username) and runs the matching lookups.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(curl:curl dig:bind); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "OSINT-LOOKUP" "OSINT aggregator — IP/domain/user/email in one pass"
  legal_warning
  log_msg "START args: $*"

  local t="${1:-}"; [[ -z "$t" ]] && { read -rp "  Target (IP/domain/email/user): " t </dev/tty || die "Target required"; }
  local out; out="$(outdir osint)"
  if is_ip "$t"; then section "IP INTEL — $t"; curl -fsS --max-time 8 "https://ipinfo.io/$t/json" | tee "$out/ipinfo.json" | sed 's/^/  /'; dig +short -x "$t" | sed 's/^/  rDNS: /'
  elif [[ "$t" == *"@"* ]]; then section "EMAIL INTEL — $t"; local d="${t#*@}"; dig +short MX "$d" | sed 's/^/  MX: /'; curl -fsS --max-time 8 "https://api.hunter.io/v2/domain-search?domain=$d" 2>/dev/null | head -5 | sed 's/^/  /' || info "Add a Hunter.io API key in ~/.cyberdeck/api-keys for deep email search."; info "Breach check (manual, needs key): https://haveibeenpwned.com/account/$t"
  elif [[ "$t" == *"."* ]]; then section "DOMAIN INTEL — $t"; whois "$t" 2>/dev/null | grep -iE 'registrar|creation|expir|name server|org' | head -20 | sed 's/^/  /' | tee "$out/whois.txt"; dig +short "$t" A MX NS TXT | sed 's/^/  DNS: /'; curl -fsSI --max-time 8 "https://$t" 2>/dev/null | head -12 | sed 's/^/  /'
  else section "USERNAME INTEL — $t"; for s in "github.com/$t" "gitlab.com/$t" "twitter.com/$t" "instagram.com/$t" "reddit.com/user/$t"; do code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 6 -L "https://$s")"; [[ "$code" == "200" ]] && online "$s" || offline "$s ($code)"; done; fi
  ok "Saved to $out"
  log_msg "DONE rc=$?"
}
main "$@"
