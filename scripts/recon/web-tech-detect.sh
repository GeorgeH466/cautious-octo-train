#!/usr/bin/env bash
# web-tech-detect.sh — Website technology / WAF fingerprinting
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
  cyber_banner "WEB-TECH-DETECT" "Website technology / WAF fingerprinting"
  cat <<USAGE
  USAGE: web-tech-detect.sh <url>
  whatweb + wafw00f when present, plus header/HTML heuristics (CMS, frameworks, servers).
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(curl:curl); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "WEB-TECH-DETECT" "Website technology / WAF fingerprinting"
  :
  log_msg "START args: $*"

  local url="${1:-}"; [[ -z "$url" ]] && die "Usage: web-tech-detect <url>"; [[ "$url" != http* ]] && url="https://$url"
  section "TECHNOLOGY — $url"
  have whatweb && whatweb --no-color "$url" 2>/dev/null | sed 's/^/  /'
  have wafw00f && { section "WAF DETECTION"; wafw00f "$url" 2>/dev/null | grep -E 'is behind|No WAF' | sed 's/^/  /'; }
  local h b; h="$(curl -fsSI --max-time 10 "$url" 2>/dev/null)"; b="$(curl -fsSL --max-time 10 "$url" 2>/dev/null | head -c 200000)"
  section "HEURISTICS"
  echo "$h" | grep -iE '^(server|x-powered|x-generator|via|cf-ray|set-cookie)' | sed 's/^/  hdr: /'
  grep -qi 'wp-content' <<<"$b" && ok "WordPress detected"; grep -qi '/_next/' <<<"$b" && ok "Next.js detected"; grep -qi 'react' <<<"$b" && ok "React hints"; grep -qi 'drupal' <<<"$b" && ok "Drupal detected"; grep -qi 'csrf' <<<"$b" && info "CSRF token present"
  grep -oE '<meta name="generator" content="[^"]+"' <<<"$b" | sed 's/^/  /'; ok "Fingerprint complete."
  log_msg "DONE rc=$?"
}
main "$@"
