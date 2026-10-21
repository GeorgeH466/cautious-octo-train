#!/usr/bin/env bash
# mission-control.sh — Main cyberdeck control panel (dialog TUI → Python TUI)
# Cyberdeck-BlackArch | MIT | Part of scripts/cyberdeck/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "MISSION-CONTROL" "Main cyberdeck control panel (dialog TUI → Python TUI)"; cat <<USAGE
  USAGE: mission-control.sh [--python|--dialog]
  Launches the Textual Python TUI when available, otherwise a full dialog/whiptail menu of every module.
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "MISSION-CONTROL" "Main cyberdeck control panel (dialog TUI → Python TUI)"; log_msg "START args: $*"

  local tui="$_SDIR/../../tui/cyberdeck-tui.py"; [[ -f "$tui" ]] || tui="$HOME/.cyberdeck/tui/cyberdeck-tui.py"
  local PY="python3"; [[ -x "$HOME/.cyberdeck/venv/bin/python" ]] && PY="$HOME/.cyberdeck/venv/bin/python"
  if [[ "${1:-}" != "--dialog" && -f "$tui" ]] && "$PY" -c 'import textual' 2>/dev/null; then exec "$PY" "$tui"; fi
  if [[ "${1:-}" != "--dialog" && -f "$tui" ]] && "$PY" -c 'import rich' 2>/dev/null; then exec "$PY" "$tui" --rich-fallback; fi
  # dialog / whiptail fallback
  local D; have dialog && D=dialog || D=whiptail; have $D || { warn "No dialog/whiptail — falling back to text menu (toolkit-menu)"; exec bash "$_SDIR/toolkit-menu.sh"; }
  while true; do
    local choice; choice="$($D --clear --title "◢ CYBERDECK MISSION CONTROL" --menu "SYS $(hostname) · $(local_ip) · theme:$CYBERDECK_THEME" 22 78 14 \
      status "▸ Status board" dash "▸ Dashboards (tmux)" net "▸ Network tools" recon "▸ Recon tools" exploit "▸ Exploit tools" defense "▸ Defense tools" crypto "▸ Crypto tools" system "▸ System tools" theme "▸ Switch theme" logs "▸ Log viewer" cheat "▸ Cheatsheet" quit "✖ Exit" 3>&1 1>&2 2>&3)" || break
    case "$choice" in
      status) bash "$_SDIR/status-board.sh"; pause_enter;;
      dash) bash "$_SDIR/../ui/dashboard.sh" "$(printf 'main\nnetwork\nrecon\ndefense\ncrypto' | $D --stdout --menu Dashboard 14 50 5 main Main network Network recon Recon defense Defense crypto Crypto)" ;;
      net|recon|exploit|defense|crypto|system) bash "$_SDIR/toolkit-menu.sh" "$choice";;
      theme) bash "$_SDIR/../ui/theme-switcher.sh";;
      logs) bash "$_SDIR/log-viewer.sh";;
      cheat) bash "$_SDIR/cheatsheet.sh";;
      quit|"") break;;
    esac
  done; clear 2>/dev/null; ok "Mission Control closed."
  log_msg "DONE"; }
main "$@"
