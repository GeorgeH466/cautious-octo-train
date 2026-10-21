#!/usr/bin/env bash
# wayback-fetch.sh — Wayback Machine URL & snapshot fetcher
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
  cyber_banner "WAYBACK-FETCH" "Wayback Machine URL & snapshot fetcher"
  cat <<USAGE
  USAGE: wayback-fetch.sh <domain|url> [limit]
  Lists archived URLs (CDX API) — great for forgotten endpoints & old files.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(curl:curl); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "WAYBACK-FETCH" "Wayback Machine URL & snapshot fetcher"
  :
  log_msg "START args: $*"

  local t="${1:-}"; local limit="${2:-200}"; [[ -z "$t" ]] && die "Usage: wayback-fetch <domain> [limit]"
  local out; out="$(outdir wayback)"
  curl -fsS --max-time 60 "http://web.archive.org/cdx/search/cdx?url=$t/*&output=text&fl=timestamp,original,statuscode&collapse=urlkey&limit=$limit" | tee "$out/urls.txt" | head -50 | sed 's/^/  /'
  ok "$(wc -l <"$out/urls.txt") archived URLs → $out/urls.txt"
  grep -iE '\.(sql|bak|zip|tar|env|log|php|asp|jsp)(\?|$)' "$out/urls.txt" | head -20 | sed 's/^/  [▲] interesting: /' 
  log_msg "DONE rc=$?"
}
main "$@"
