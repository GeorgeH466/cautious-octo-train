#!/usr/bin/env bash
# toolkit-menu.sh — Categorized launcher for every cyberdeck module
# Cyberdeck-BlackArch | MIT | Part of scripts/cyberdeck/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "TOOLKIT-MENU" "Categorized launcher for every cyberdeck module"; cat <<USAGE
  USAGE: toolkit-menu.sh [network|recon|exploit|defense|crypto|system|ui|cyberdeck]
  Lists modules in a category with descriptions; pick a number to launch (passes through extra args after --).
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "TOOLKIT-MENU" "Categorized launcher for every cyberdeck module"; log_msg "START args: $*"

  local cat="${1:-}"
  local base="$_SDIR/../.."; [[ -d "$base/scripts" ]] || base="$HOME/.cyberdeck"
  if [[ -z "$cat" ]]; then section "CATEGORIES"; local cats=(network recon exploit defense crypto system ui cyberdeck); local i=1; for c in "${cats[@]}"; do printf '  %d ▸ %-10s (%s modules)\n' "$i" "$c" "$(ls "$base/scripts/$c"/*.sh 2>/dev/null|wc -l)"; i=$((i+1)); done; printf '  Category #: '; read -r n </dev/tty; cat="${cats[n-1]:-}"; [[ -z "$cat" ]] && exit 0; fi
  [[ -d "$base/scripts/$cat" ]] || die "Unknown category '$cat'"
  section "${cat^^} MODULES"
  local -a files=("$base/scripts/$cat"/*.sh); local i=1
  for f in "${files[@]}"; do printf '  %2d ▸ %-24s %s\n' "$i" "$(basename "$f" .sh)" "$(grep -m1 '^# .*\.sh —' "$f"|sed 's/.*— //')"; i=$((i+1)); done
  printf '  Launch # (blank=quit): '; read -r n </dev/tty; [[ -z "$n" ]] && exit 0
  local chosen="${files[n-1]:-}"; [[ -n "$chosen" ]] || die "Invalid selection"
  printf '  Args for %s (blank=none, --help works): ' "$(basename "$chosen")"; read -r extra </dev/tty
  log_msg "toolkit launch $chosen $extra"; exec bash "$chosen" $extra
  log_msg "DONE"; }
main "$@"
