#!/usr/bin/env bash
# google-dork.sh — Google dork query builder (opens or prints queries)
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
  cyber_banner "GOOGLE-DORK" "Google dork query builder (opens or prints queries)"
  cat <<USAGE
  USAGE: google-dork.sh <domain> [--open]
  Prints a battery of dorks (files, logins, indexes, errors). --open launches them in the browser.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# no external deps beyond coreutils
main() {
  cyber_banner "GOOGLE-DORK" "Google dork query builder (opens or prints queries)"
  :
  log_msg "START args: $*"

  local d="${1:-}"; [[ -z "$d" ]] && die "Usage: google-dork <domain> [--open]"
  local -a dorks=("site:$d filetype:pdf" "site:$d filetype:sql|filetype:log|filetype:env" "site:$d intitle:index.of" "site:$d inurl:admin|inurl:login" "site:$d inurl:php?id=" "site:$d \"password\" filetype:txt" "site:$d ext:bak|ext:old|ext:zip" "site:$d \"index of\" \"parent directory\"" "site:$d intext:\"sql syntax\" | intext:\"fatal error\"" "site:pastebin.com \"$d\"" "site:github.com \"$d\" password")
  section "DORKS FOR $d"
  for q in "${dorks[@]}"; do local enc; enc="$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$q")"; printf '  %s▸%s %s\n    https://www.google.com/search?q=%s\n' "$C_PRIMARY" "$C_RESET" "$q" "$enc"; [[ "${2:-}" == "--open" ]] && (xdg-open "https://www.google.com/search?q=$enc" >/dev/null 2>&1 &); sleep 0.2; done
  ok "Respect target ToS — dorking is recon, not authorisation."
  log_msg "DONE rc=$?"
}
main "$@"
