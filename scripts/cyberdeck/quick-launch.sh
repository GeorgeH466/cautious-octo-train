#!/usr/bin/env bash
# quick-launch.sh — Quick-launch menu for frequent tasks (rofi or fzf or numbered)
# Cyberdeck-BlackArch | MIT | Part of scripts/cyberdeck/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "QUICK-LAUNCH" "Quick-launch menu for frequent tasks (rofi or fzf or numbered)"; cat <<USAGE
  USAGE: quick-launch.sh — pick a task: scans, dashboards, monitors, theme, lock, update…
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "QUICK-LAUNCH" "Quick-launch menu for frequent tasks (rofi or fzf or numbered)"; log_msg "START args: $*"

  local -a labels=("Mission Control TUI" "Main Dashboard" "Network Dashboard" "Quick LAN Scan" "Discover Hosts" "Wi-Fi Scan" "Traffic Monitor" "System Status" "Process Monitor" "Switch Theme" "Lock Screen" "Update Everything" "Matrix Rain")
  local pick=""
  if [[ -n "${DISPLAY:-}" ]] && have rofi; then pick="$(printf '%s\n' "${labels[@]}" | rofi -dmenu -p '◢ QUICK LAUNCH')"
  elif have fzf; then pick="$(printf '%s\n' "${labels[@]}" | fzf --prompt='◢ QUICK LAUNCH ▸ ')"
  else local i=1; for l in "${labels[@]}"; do printf '  %2d ▸ %s\n' "$i" "$l"; i=$((i+1)); done; printf '  Choice: '; read -r n </dev/tty; pick="${labels[n-1]:-}"; fi
  log_msg "quick-launch: $pick"
  case "$pick" in
    "Mission Control TUI") exec bash "$_SDIR/mission-control.sh";;
    "Main Dashboard") exec bash "$_SDIR/../ui/dashboard.sh" main;;
    "Network Dashboard") exec bash "$_SDIR/../ui/dashboard.sh" network;;
    "Quick LAN Scan") exec bash "$_SDIR/../network/net-scan.sh";;
    "Discover Hosts") exec bash "$_SDIR/../network/net-discover.sh";;
    "Wi-Fi Scan") exec bash "$_SDIR/../network/wifi-scan.sh";;
    "Traffic Monitor") exec bash "$_SDIR/../network/traffic-monitor.sh";;
    "System Status") exec bash "$_SDIR/status-board.sh";;
    "Process Monitor") exec bash "$_SDIR/../defense/process-monitor.sh";;
    "Switch Theme") exec bash "$_SDIR/../ui/theme-switcher.sh";;
    "Lock Screen") exec bash "$_SDIR/../ui/lock-screen.sh";;
    "Update Everything") exec bash "$_SDIR/../system/update-all.sh";;
    "Matrix Rain") exec bash "$_SDIR/../ui/matrix-rain.sh";;
    *) info "Nothing selected.";;
  esac
  log_msg "DONE"; }
main "$@"
