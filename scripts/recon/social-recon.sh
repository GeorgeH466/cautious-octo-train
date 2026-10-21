#!/usr/bin/env bash
# social-recon.sh — Username presence checker across platforms
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
  cyber_banner "SOCIAL-RECON" "Username presence checker across platforms"
  cat <<USAGE
  USAGE: social-recon.sh <username>
  Checks ~25 platforms by HTTP status/profile markers. Respect privacy & platform ToS.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(curl:curl); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "SOCIAL-RECON" "Username presence checker across platforms"
  legal_warning
  log_msg "START args: $*"

  local u="${1:-}"; [[ -z "$u" ]] && die "Usage: social-recon <username>"
  have sherlock && { info "sherlock found — running full check…"; sherlock "$u" --timeout 8 2>/dev/null | grep -E '^\[\+\]' | sed 's/^/  /' | tee -a "$LOG_FILE"; exit 0; }
  section "USERNAME: $u"
  local -a sites=("github.com/$u" "gitlab.com/$u" "twitter.com/$u" "instagram.com/$u" "reddit.com/user/$u" "twitch.tv/$u" "youtube.com/@$u" "tiktok.com/@$u" "medium.com/@$u" "dev.to/$u" "stackoverflow.com/users/$u" "keybase.io/$u" "hackerone.com/$u" "tryhackme.com/p/$u" "app.hackthebox.com/profile/$u" "codepen.io/$u" "replit.com/@$u" "pypi.org/user/$u" "hub.docker.com/u/$u")
  for s in "${sites[@]}"; do local code; code="$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 8 -A 'Mozilla/5.0' "https://$s")"; if [[ "$code" == "200" ]]; then online "https://$s"; log_msg "found $s"; else offline "$s ($code)"; fi; done
  ok "Done — 200 can occasionally be a soft-404; verify manually."
  log_msg "DONE rc=$?"
}
main "$@"
