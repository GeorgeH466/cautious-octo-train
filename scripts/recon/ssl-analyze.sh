#!/usr/bin/env bash
# ssl-analyze.sh — SSL/TLS certificate & cipher analyzer
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
  cyber_banner "SSL-ANALYZE" "SSL/TLS certificate & cipher analyzer"
  cat <<USAGE
  USAGE: ssl-analyze.sh <host> [port]
  Certificate chain, expiry countdown, protocol/cipher support, HSTS check.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(openssl:openssl); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "SSL-ANALYZE" "SSL/TLS certificate & cipher analyzer"
  :
  log_msg "START args: $*"

  local host="${1:-}"; local port="${2:-443}"; [[ -z "$host" ]] && die "Usage: ssl-analyze <host> [port]"
  section "CERTIFICATE — $host:$port"
  local cert; cert="$(echo | openssl s_client -connect "$host:$port" -servername "$host" 2>/dev/null | openssl x509 -noout -subject -issuer -dates -fingerprint -ext subjectAltName 2>/dev/null)"
  echo "$cert" | sed 's/^/  /' | tee -a "$LOG_FILE"
  local end; end="$(echo | openssl s_client -connect "$host:$port" -servername "$host" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)"
  local days=$(( ( $(date -d "$end" +%s) - $(date +%s) ) / 86400 )); (( days < 30 )) && warn "Expires in $days days!" || ok "Valid for $days more days"
  section "PROTOCOL SUPPORT"
  for p in tls1 tls1_1 tls1_2 tls1_3; do if echo | openssl s_client -connect "$host:$port" -"$p" 2>/dev/null | grep -q 'Verify return code'; then online "$p"; else offline "$p"; fi; done
  curl -fsSI --max-time 8 "https://$host" 2>/dev/null | grep -qi strict-transport && ok "HSTS enabled" || warn "No HSTS header"
  have sslscan && { info "sslscan full audit available: sslscan $host:$port"; }
  log_msg "DONE rc=$?"
}
main "$@"
