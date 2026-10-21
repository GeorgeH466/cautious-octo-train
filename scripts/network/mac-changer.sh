#!/usr/bin/env bash
# mac-changer.sh — MAC address randomizer / restorer
# Cyberdeck-BlackArch | MIT | Part of scripts/network/
set -uo pipefail
# ── locate shared libraries ──────────────────────────────────────────────
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do
  [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }
done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh";
else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi

usage() {
  cyber_banner "MAC-CHANGER" "MAC address randomizer / restorer"
  cat <<USAGE
  USAGE: mac-changer.sh <random|restore|show|set AA:BB:..> [interface]
  Example: mac-changer.sh random wlan0
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(ip:iproute2); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "MAC-CHANGER" "MAC address randomizer / restorer"
  :
  log_msg "START args: $*"

  local action="${1:-show}" iface="${2:-$(default_iface)}"
  [[ "$action" == "set" ]] && iface="${3:-$(default_iface)}"
  local cur; cur="$(cat /sys/class/net/$iface/address 2>/dev/null)"; [[ -z "$cur" ]] && die "Interface $iface not found."
  local perm="$CYBERDECK_HOME/.orig-mac-$iface"
  case "$action" in
    show) kv "Interface" "$iface"; kv "Current MAC" "$cur"; [[ -f "$perm" ]] && kv "Original MAC" "$(cat $perm)" ;;
    random|set) require_root "$@"; [[ -f "$perm" ]] || echo "$cur" >"$perm"
      local new="$2"; [[ "$action" == "random" ]] && { if have macchanger; then sudo macchanger -r "$iface"|sed 's/^/  /'; log_msg "mac random $iface"; ok "Randomized."; exit 0; fi; new="$(printf '02:%02x:%02x:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))"; }
      sudo ip link set "$iface" down; sudo ip link set "$iface" address "$new"; sudo ip link set "$iface" up
      log_msg "MAC $iface $cur -> $new"; ok "$iface MAC now $new (original saved, restore with: mac-changer restore $iface)" ;;
    restore) require_root "$@"; [[ -f "$perm" ]] || die "No saved original MAC for $iface"
      if have macchanger; then sudo macchanger -p "$iface"; else sudo ip link set "$iface" down; sudo ip link set "$iface" address "$(cat $perm)"; sudo ip link set "$iface" up; fi; ok "Original MAC restored." ;;
    *) die "Usage: mac-changer.sh random|restore|show|set <MAC> [iface]" ;;
  esac
  log_msg "DONE rc=$?"
}
main "$@"
