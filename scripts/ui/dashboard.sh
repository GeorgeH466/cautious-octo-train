#!/usr/bin/env bash
# dashboard.sh — Launch a tmux operational dashboard by name
# Cyberdeck-BlackArch | MIT | Part of scripts/ui/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "DASHBOARD-LAUNCHER" "Launch a tmux operational dashboard by name"; cat <<USAGE
  USAGE: dashboard.sh [main|network|recon|defense|crypto] — thin wrapper over dashboards/*.sh (see also: cyberdeck dashboard)
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(tmux:tmux); check_deps "${DEPS[@]}" || exit 1
main() { cyber_banner "DASHBOARD-LAUNCHER" "Launch a tmux operational dashboard by name"; log_msg "START args: $*"

  local name="${1:-main}"; local base="$_SDIR/../../dashboards"; [[ -d "$base" ]] || base="$HOME/.cyberdeck/dashboards"
  local file="$base/$name-dashboard.sh"; [[ "$name" == "main" ]] && file="$base/main-dashboard.sh"; [[ "$name" == "network" ]] && file="$base/network-ops.sh"
  [[ -x "$file" ]] || { section "DASHBOARDS"; ls "$base" 2>/dev/null | sed 's/^/  ▸ /'; die "Dashboard '$name' not found"; }
  exec bash "$file" "$@"
  log_msg "DONE"; }
main "$@"
