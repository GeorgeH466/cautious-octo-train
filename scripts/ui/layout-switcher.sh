#!/usr/bin/env bash
# layout-switcher.sh — Switch i3 workspace layouts (ops layouts in config/i3/workspace-layouts)
# Cyberdeck-BlackArch | MIT | Part of scripts/ui/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "LAYOUT-SWITCHER" "Switch i3 workspace layouts (ops layouts in config/i3/workspace-layouts)"; cat <<USAGE
  USAGE: layout-switcher.sh [dashboard|network|recon|defense|crypto|minimal]
  Loads a saved i3 layout JSON onto the current workspace and spawns its apps.
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "LAYOUT-SWITCHER" "Switch i3 workspace layouts (ops layouts in config/i3/workspace-layouts)"; log_msg "START args: $*"

  local layout="${1:-}"
  local dir="$HOME/.config/i3/workspace-layouts"; [[ -d "$dir" ]] || dir="$_SDIR/../../config/i3/workspace-layouts"
  if [[ -z "$layout" ]]; then section "LAYOUTS"; ls "$dir"/*.json 2>/dev/null | xargs -rn1 basename | sed 's/.json//;s/^/  ▸ /'; printf '  Layout: '; read -r layout </dev/tty; fi
  [[ -f "$dir/$layout.json" ]] || die "Layout '$layout' not found in $dir"
  have i3-msg || die "i3-msg not available (are you in i3?)"
  i3-msg "append_layout $dir/$layout.json" >/dev/null
  # Spawn the apps that swallow into the layout placeholders
  case "$layout" in
    network) (alacritty -e bash -c 'traffic-monitor' &); (alacritty -e bash -c 'connection-monitor --watch' &);;
    dashboard) (alacritty -e cyberdeck dashboard main &);;
    recon) (alacritty &); (firefox &);;
    defense) (alacritty -e bash -c 'process-monitor; exec $SHELL' &); (alacritty -e bash -c 'journalctl -f' &);;
    crypto) (alacritty -e cyberdeck dashboard crypto &);;
    *) (alacritty &);;
  esac
  ok "Layout '$layout' loaded."
  log_msg "DONE"; }
main "$@"
