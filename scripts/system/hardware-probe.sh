#!/usr/bin/env bash
# hardware-probe.sh — Hardware detection — CPU/GPU/USB/PCI/battery/sensors
# Cyberdeck-BlackArch | MIT | Part of scripts/system/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "HARDWARE-PROBE" "Hardware detection — CPU/GPU/USB/PCI/battery/sensors"; cat <<USAGE
  USAGE: hardware-probe.sh [cpu|gpu|usb|pci|disk|battery|net|all]
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "HARDWARE-PROBE" "Hardware detection — CPU/GPU/USB/PCI/battery/sensors"; :; log_msg "START args: $*"

  local what="${1:-all}"
  [[ "$what" == "all" || "$what" == "cpu" ]] && { section "CPU"; lscpu 2>/dev/null | grep -E 'Model name|Architecture|^CPU\(s\)|Thread|Core|MHz|L3' | sed 's/^/  /'; }
  [[ "$what" == "all" || "$what" == "gpu" ]] && { section "GPU"; lspci 2>/dev/null | grep -iE 'vga|3d|display' | sed 's/^/  /'; have nvidia-smi && nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used --format=csv 2>/dev/null | sed 's/^/  /'; }
  [[ "$what" == "all" || "$what" == "usb" ]] && { section "USB DEVICES"; lsusb 2>/dev/null | sed 's/^/  /'; }
  [[ "$what" == "all" || "$what" == "pci" ]] && { section "PCI DEVICES"; lspci 2>/dev/null | sed 's/^/  /' | head -30; }
  [[ "$what" == "all" || "$what" == "disk" ]] && { section "STORAGE"; lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL 2>/dev/null | sed 's/^/  /'; }
  [[ "$what" == "all" || "$what" == "battery" ]] && { section "BATTERY / POWER"; for b in /sys/class/power_supply/BAT*; do [[ -e "$b/capacity" ]] && printf '  %s: %s%% (%s)\n' "$(basename $b)" "$(cat $b/capacity)" "$(cat $b/status)"; done; have sensors && sensors 2>/dev/null | grep -E 'Core|Package|fan' | head -8 | sed 's/^/  /'; }
  [[ "$what" == "all" || "$what" == "net" ]] && { section "NETWORK ADAPTERS"; ip -brief link | sed 's/^/  /'; iw dev 2>/dev/null | grep Interface | sed 's/^/  wifi: /'; }
  log_msg "DONE"; }
main "$@"
