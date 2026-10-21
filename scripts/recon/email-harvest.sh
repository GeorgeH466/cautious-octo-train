#!/usr/bin/env bash
# email-harvest.sh — Email address harvester for a domain
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
  cyber_banner "EMAIL-HARVEST" "Email address harvester for a domain"
  cat <<USAGE
  USAGE: email-harvest.sh <domain>
  Uses theHarvester when present; otherwise scrapes the site + common search patterns.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(curl:curl); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "EMAIL-HARVEST" "Email address harvester for a domain"
  legal_warning
  log_msg "START args: $*"

  local d="${1:-}"; [[ -z "$d" ]] && die "Usage: email-harvest <domain>"
  local out; out="$(outdir emails)"
  if have theHarvester; then theHarvester -d "$d" -b all 2>/dev/null | grep -oiE "[a-z0-9._%+-]+@[a-z0-9.-]+\.$d" | sort -u | tee "$out/emails.txt" | sed 's/^/  /'
  else info "theHarvester not found — scraping https://$d …"
    curl -fsSL --max-time 15 "https://$d" 2>/dev/null | grep -oiE "[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}" | sort -u | tee "$out/emails.txt" | sed 's/^/  /'
    warn "Install theharvester for search-engine depth: sudo pacman -S theharvester"; fi
  ok "$(wc -l <"$out/emails.txt" 2>/dev/null || echo 0) emails → $out/emails.txt"
  log_msg "DONE rc=$?"
}
main "$@"
