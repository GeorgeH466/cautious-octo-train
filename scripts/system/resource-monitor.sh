#!/usr/bin/env bash
# resource-monitor.sh — Live resource monitor (htop alternative with HUD bars)
# Cyberdeck-BlackArch | MIT | Part of scripts/system/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "RESOURCE-MONITOR" "Live resource monitor (htop alternative with HUD bars)"; cat <<USAGE
  USAGE: resource-monitor.sh [--once] — live CPU/RAM/swap/disk/net gauges; q quits.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "RESOURCE-MONITOR" "Live resource monitor (htop alternative with HUD bars)"; :; log_msg "START args: $*"

  gauge() {
    local cpu_p; cpu_p="$(awk '/^cpu /{u=$2+$4; t=$2+$4+$5; print int(u*100/t)}' /proc/stat)"
    printf '  CPU   '; bar "$cpu_p" 30; echo
    free -m | awk '/Mem/{printf "  MEM   %5d/%d MB  ",$3,$2}'; bar "$(free -m|awk '/Mem/{print int($3*100/$2)}')" 30; echo
    local sw; sw="$(free -m|awk '/Swap/{if($2>0)print int($3*100/$2); else print 0}')"; printf '  SWAP  '; bar "$sw" 30; echo
    printf '  DISK/ '; bar "$(df / --output=pcent|tail -1|tr -dc 0-9)" 30; echo
    printf '  LOAD  %s   TEMP %s°C\n' "$(cut -d' ' -f1-3 /proc/loadavg)" "$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null|awk '{print int($1/1000)}')"
    kv "Top process" "$(ps -eo comm,%cpu --sort=-%cpu --no-headers|head -1)"
  }
  if [[ "${1:-}" == "--once" ]]; then gauge; exit 0; fi
  have htop && info "Tip: htop is installed — this is the lightweight HUD view (q to quit)"
  while true; do printf '\033[H\033[2J'; cyber_banner "RESOURCE-MONITOR" "live system vitals — q quits"; gauge; read -rt 2 -n1 k </dev/tty 2>/dev/null; [[ "$k" == "q" ]] && break; done
  log_msg "DONE"; }
main "$@"
