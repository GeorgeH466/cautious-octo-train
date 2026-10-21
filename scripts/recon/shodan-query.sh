#!/usr/bin/env bash
# shodan-query.sh — Shodan search wrapper (API key in ~/.cyberdeck/api-keys)
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
  cyber_banner "SHODAN-QUERY" "Shodan search wrapper (API key in ~/.cyberdeck/api-keys)"
  cat <<USAGE
  USAGE: shodan-query.sh <query|host IP>
  Set SHODAN_API_KEY in ~/.cyberdeck/api-keys or env. Falls back to shodan CLI if installed.
  Example: shodan-query.sh 'apache country:GB'  |  shodan-query.sh 1.2.3.4
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(curl:curl); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "SHODAN-QUERY" "Shodan search wrapper (API key in ~/.cyberdeck/api-keys)"
  :
  log_msg "START args: $*"

  [[ -f "$CYBERDECK_HOME/api-keys" ]] && source "$CYBERDECK_HOME/api-keys"
  local q="${1:-}"; [[ -z "$q" ]] && die "Usage: shodan-query <query|IP>"
  if have shodan && [[ -n "${SHODAN_API_KEY:-}" ]]; then shodan init "$SHODAN_API_KEY" >/dev/null 2>&1; is_ip "$q" && shodan host "$q" | head -50 | tee -a "$LOG_FILE" || shodan search --limit 20 "$q" | tee -a "$LOG_FILE"; exit 0; fi
  [[ -z "${SHODAN_API_KEY:-}" ]] && die "Set SHODAN_API_KEY in ~/.cyberdeck/api-keys (get one at shodan.io — free tier available)"
  if is_ip "$q"; then curl -fsS "https://api.shodan.io/shodan/host/$q?key=$SHODAN_API_KEY" | python3 -m json.tool | head -80 | sed 's/^/  /'
  else local enc; enc="$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$q")"; curl -fsS "https://api.shodan.io/shodan/host/search?key=$SHODAN_API_KEY&query=$enc" | python3 -c "import json,sys; d=json.load(sys.stdin); [print(f\"  {m['ip_str']}:{m['port']}  {m.get('org','')}  {m.get('product','')}\") for m in d.get('matches',[])[:25]]"; fi
  log_msg "DONE rc=$?"
}
main "$@"
