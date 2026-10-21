#!/usr/bin/env bash
# usb-monitor.sh — USB device monitor with plug alerts + history
# Cyberdeck-BlackArch | MIT | Part of scripts/system/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "USB-MONITOR" "USB device monitor with plug alerts + history"; cat <<USAGE
  USAGE: usb-monitor.sh [--watch|--history]
  --watch: live udev monitor with desktop notifications. --history: kernel log of past devices.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "USB-MONITOR" "USB device monitor with plug alerts + history"; :; log_msg "START args: $*"

  case "${1:---once}" in
    --watch) info "Watching USB events… Ctrl-C stops"; udevadm monitor --subsystem-match=usb 2>/dev/null | while read -r l; do [[ "$l" == *"add"*usb* || "$l" == *"remove"*usb* ]] && { warn "USB: $l"; log_msg "USB $l"; have notify-send && notify-send "Cyberdeck USB" "$l"; }; done ;;
    --history) section "USB HISTORY (kernel log)"; journalctl -k --no-pager 2>/dev/null | grep -iE 'usb.*(new|disconnect)' | tail -25 | sed 's/^/  /' ;;
    *) section "CONNECTED USB DEVICES"; lsusb 2>/dev/null | sed 's/^/  /'; ok "Live mode: usb-monitor --watch" ;;
  esac
  log_msg "DONE"; }
main "$@"
