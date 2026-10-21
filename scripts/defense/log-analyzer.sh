#!/usr/bin/env bash
# log-analyzer.sh — Log file analyzer — auth failures, errors, top talkers
# Cyberdeck-BlackArch | MIT | Part of scripts/defense/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "LOG-ANALYZER" "Log file analyzer — auth failures, errors, top talkers"; cat <<USAGE
  USAGE: log-analyzer.sh [file|--journal [unit]] 
  Default: analyses journal last 24h (failed logins, sudo, service failures, error heat).
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "LOG-ANALYZER" "Log file analyzer — auth failures, errors, top talkers"; :; log_msg "START args: $*"

  local src="${1:---journal}"
  if [[ "$src" == "--journal" ]]; then
    section "FAILED LOGINS (24h)"; journalctl --since "-24h" -u sshd --no-pager 2>/dev/null | grep -ci 'failed password' | sed 's/^/  count: /'; journalctl --since "-24h" -u sshd --no-pager 2>/dev/null | grep -i 'failed password' | grep -oE 'from [0-9.]+' | sort | uniq -c | sort -rn | head | sed 's/^/  /'
    section "SUDO USE"; journalctl --since "-24h" --no-pager 2>/dev/null | grep -E 'sudo.*COMMAND' | tail -10 | sed 's/^/  /'
    section "FAILED UNITS"; systemctl --failed --no-legend 2>/dev/null | sed 's/^/  /' || ok "none"
    section "ERROR HEAT (by unit)"; journalctl --since "-24h" -p err --no-pager 2>/dev/null | grep -oE '[a-z0-9_.-]+\[[0-9]+\]' | sed 's/\[.*//' | sort | uniq -c | sort -rn | head | sed 's/^/  /'
  else [[ -f "$src" ]] || die "File not found: $src"; section "FILE: $src"; wc -l "$src" | sed 's/^/  lines: /'
    for p in error fail denied 'invalid user' 'authentication failure'; do printf '  %-24s %s\n' "$p:" "$(grep -ci "$p" "$src")"; done
    section "TOP IPs"; grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$src" | sort | uniq -c | sort -rn | head | sed 's/^/  /'
    section "RECENT ERRORS"; grep -iE 'error|fail|denied' "$src" | tail -15 | sed 's/^/  /'; fi
  ok "Analysis complete."
  log_msg "DONE"; }
main "$@"
