#!/usr/bin/env bash
# subdomain-enum.sh — Subdomain enumeration (crt.sh + brute + tools)
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
  cyber_banner "SUBDOMAIN-ENUM" "Subdomain enumeration (crt.sh + brute + tools)"
  cat <<USAGE
  USAGE: subdomain-enum.sh <domain> [wordlist]
  Passive: crt.sh certificate transparency. Active: wordlist brute + sublist3r/amass if present.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(curl:curl dig:bind); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "SUBDOMAIN-ENUM" "Subdomain enumeration (crt.sh + brute + tools)"
  legal_warning
  log_msg "START args: $*"

  local d="${1:-}"; [[ -z "$d" ]] && die "Usage: subdomain-enum <domain> [wordlist]"
  local out; out="$(outdir subdomains)"
  section "CERTIFICATE TRANSPARENCY (crt.sh)"
  curl -fsS --max-time 30 "https://crt.sh/?q=%25.$d&output=json" 2>/dev/null | grep -oE '"name_value":"[^"]+"' | cut -d'"' -f4 | tr '\n' '\n' | sed 's/^\*.//' | sort -u | tee "$out/crtsh.txt" | sed 's/^/  /'
  have sublist3r && { section "SUBLIST3R"; sublist3r -d "$d" -o "$out/sublist3r.txt" 2>/dev/null | tail -20 | sed 's/^/  /'; }
  have amass && { section "AMASS (passive)"; timeout 120 amass enum -passive -d "$d" -o "$out/amass.txt" 2>/dev/null | head -30 | sed 's/^/  /'; }
  if [[ -n "${2:-}" ]]; then section "BRUTE FORCE"; while read -r s; do dig +short "$s.$d" | grep -q . && echo "$s.$d"; done <"$2" | tee "$out/brute.txt" | sed 's/^/  /'; fi
  cat "$out"/*.txt 2>/dev/null | sort -u >"$out/all.txt"; ok "$(wc -l <"$out/all.txt") unique subdomains → $out/all.txt"
  log_msg "DONE rc=$?"
}
main "$@"
