#!/usr/bin/env bash
# log-viewer.sh — Centralized cyberdeck + system log viewer with filtering
# Cyberdeck-BlackArch | MIT | Part of scripts/cyberdeck/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "LOG-VIEWER" "Centralized cyberdeck + system log viewer with filtering"; cat <<USAGE
  USAGE: log-viewer.sh [cyberdeck|journal|auth|kern] [filter] [--follow]
  Examples: log-viewer cyberdeck ERROR --follow | log-viewer journal sshd
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "LOG-VIEWER" "Centralized cyberdeck + system log viewer with filtering"; log_msg "START args: $*"

  local src="${1:-cyberdeck}" filter="${2:-}" follow=""; [[ "$*" == *"--follow"* ]] && follow=1; [[ "$filter" == "--follow" ]] && filter=""
  local cmd=""
  case "$src" in
    cyberdeck) cmd="cat $CYBERDECK_LOG_DIR/*.log 2>/dev/null | sort"; [[ -n "$follow" ]] && cmd="tail -F $CYBERDECK_LOG_DIR/*.log";;
    journal) cmd="journalctl --no-pager -n 300 ${follow:+-f}";;
    auth) cmd="journalctl --no-pager -n 300 -u sshd -u sudo ${follow:+-f} 2>/dev/null || tail -n 300 /var/log/auth.log";;
    kern) cmd="journalctl -k --no-pager -n 300 ${follow:+-f}";;
    *) die "Source must be cyberdeck|journal|auth|kern";;
  esac
  section "LOGS: $src ${filter:+/ filter: $filter}"
  if [[ -n "$filter" ]]; then eval "$cmd" 2>/dev/null | grep --color=never -iE "$filter" | sed -E "s/(error|fail|denied|fatal)/${C_RED}\1${C_RESET}/gi; s/(warn|▲)/${C_AMBER}\1${C_RESET}/gi" | tail -100
  else eval "$cmd" 2>/dev/null | tail -80 | sed 's/^/  /'; fi
  log_msg "DONE"; }
main "$@"
