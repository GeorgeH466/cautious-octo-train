#!/usr/bin/env bash
# service-manager.sh — Systemd service manager with cyberdeck presets
# Cyberdeck-BlackArch | MIT | Part of scripts/system/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "SERVICE-MANAGER" "Systemd service manager with cyberdeck presets"; cat <<USAGE
  USAGE: service-manager.sh <list|failed|start|stop|restart|enable|disable|status <unit>|presets>
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "SERVICE-MANAGER" "Systemd service manager with cyberdeck presets"; :; log_msg "START args: $*"

  local action="${1:-list}" unit="${2:-}"
  case "$action" in
    list) systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | awk '{print "  [▓] "$1}' | head -40 ;;
    failed) systemctl --failed --no-pager 2>/dev/null | sed 's/^/  /' ;;
    presets) for u in tor sshd NetworkManager bluetooth docker fail2ban ufw; do printf '  %-18s %s\n' "$u" "$(systemctl is-active $u 2>/dev/null)"; done ;;
    start|stop|restart|enable|disable) [[ -z "$unit" ]] && die "unit required"; sudo systemctl "$action" "$unit" && ok "$action $unit done"; log_msg "svc $action $unit" ;;
    status) systemctl status "${unit:?}" --no-pager 2>/dev/null | head -18 | sed 's/^/  /' ;;
    *) die "Usage: service-manager list|failed|presets|start|stop|restart|enable|disable|status <unit>" ;;
  esac
  log_msg "DONE"; }
main "$@"
