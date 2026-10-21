#!/usr/bin/env bash
# ascii-banner.sh — ASCII art banner generator (figlet/toilet/pyfiglet fallback)
# Cyberdeck-BlackArch | MIT | Part of scripts/ui/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "ASCII-BANNER" "ASCII art banner generator (figlet/toilet/pyfiglet fallback)"; cat <<USAGE
  USAGE: ascii-banner.sh <text...> [--font name]
  Example: ascii-banner.sh CYBERDECK ONLINE
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "ASCII-BANNER" "ASCII art banner generator (figlet/toilet/pyfiglet fallback)"; log_msg "START args: $*"

  [[ -n "${1:-}" ]] || die "Usage: ascii-banner <text>"
  local font="standard" text=()
  while [[ $# -gt 0 ]]; do case "$1" in --font) font="$2"; shift 2;; *) text+=("$1"); shift;; esac; done
  printf '%s%s' "$C_PRIMARY" "$C_BOLD"
  if have figlet; then figlet -f "$font" "${text[*]}" 2>/dev/null || figlet "${text[*]}"
  elif have toilet; then toilet -f bigmono12 "${text[*]}" 2>/dev/null || toilet "${text[*]}"
  elif python3 -c 'import pyfiglet' 2>/dev/null; then python3 -c "import pyfiglet,sys;print(pyfiglet.figlet_format(' '.join(sys.argv[1:])))" "${text[@]}"
  else local t="${text[*]}"; printf '  ┌%s┐\n  │  %s  │\n  └%s┘\n' "$(printf '─%.0s' $(seq 1 $((${#t}+4))))" "$t" "$(printf '─%.0s' $(seq 1 $((${#t}+4))))"; warn "Install figlet for full ASCII fonts: sudo pacman -S figlet"; fi
  printf '%s' "$C_RESET"
  log_msg "DONE"; }
main "$@"
