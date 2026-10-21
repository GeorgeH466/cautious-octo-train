#!/usr/bin/env bash
# header-analyze.sh — HTTP security header analyzer with grading
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
  cyber_banner "HEADER-ANALYZE" "HTTP security header analyzer with grading"
  cat <<USAGE
  USAGE: header-analyze.sh <url> — grades A+..F on HSTS/CSP/XFO/nosniff/Referrer/Permissions.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(curl:curl); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "HEADER-ANALYZE" "HTTP security header analyzer with grading"
  :
  log_msg "START args: $*"

  local url="${1:-}"; [[ -z "$url" ]] && die "Usage: header-analyze <url>"; [[ "$url" != http* ]] && url="https://$url"
  local h score=0 total=6; h="$(curl -fsSI --max-time 10 -L "$url" 2>/dev/null)"; [[ -z "$h" ]] && die "No response from $url"
  section "RESPONSE — $url"; echo "$h" | head -20 | sed 's/^/  /'
  section "SECURITY HEADERS"
  check() { if grep -qi "^$1:" <<<"$h"; then ok "$1: $(grep -i "^$1:" <<<"$h"|head -1|cut -d: -f2-|xargs|head -c 70)"; score=$((score+1)); else err "$1: MISSING — $2"; fi; }
  check strict-transport-security "add HSTS (max-age=63072000; includeSubDomains)"
  check content-security-policy "define a CSP to blunt XSS"
  check x-frame-options "DENY/SAMEORIGIN stops clickjacking (or CSP frame-ancestors)"
  check x-content-type-options "nosniff stops MIME confusion"
  check referrer-policy "e.g. strict-origin-when-cross-origin"
  check permissions-policy "restrict camera/mic/geolocation features"
  local grade=F; case $score in 6) grade="A+";; 5) grade=A;; 4) grade=B;; 3) grade=C;; 2) grade=D;; esac
  printf '\n  %sSCORE: %s (%d/%d)%s  ' "$C_BOLD" "$grade" "$score" "$total" "$C_RESET"; bar $((score*100/total)); echo; grep -qi 'set-cookie' <<<"$h" && { grep -i 'set-cookie' <<<"$h" | grep -qiv 'secure' && warn "Cookie without Secure flag"; grep -i 'set-cookie' <<<"$h" | grep -qiv 'httponly' && warn "Cookie without HttpOnly flag"; }
  log_msg "DONE rc=$?"
}
main "$@"
