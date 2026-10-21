#!/usr/bin/env bash
# lib/ui.sh — Banner, boxes, tables, spinners, menus for Cyberdeck
[[ -n "${_CYBERDECK_UI_LOADED:-}" ]] && return 0
_CYBERDECK_UI_LOADED=1
_UI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=colors.sh
[[ -f "$_UI_DIR/colors.sh" ]] && source "$_UI_DIR/colors.sh"
[[ -f "$HOME/.cyberdeck/lib/colors.sh" && -z "${_CYBERDECK_COLORS_LOADED:-}" ]] && source "$HOME/.cyberdeck/lib/colors.sh"

term_width() { local w; w="$(tput cols 2>/dev/null || echo 100)"; [[ "$w" -gt 120 ]] && w=120; [[ "$w" -lt 60 ]] && w=60; echo "$w"; }
hline() { local w; w="$(term_width)"; printf '%s' "${C_MUTED}"; printf '─%.0s' $(seq 1 "$w"); printf '%s\n' "${C_RESET}"; }

cyber_banner() {
  local title="${1:-CYBERDECK}" sub="${2:-BLACKARCH // SCI-FI OPERATIONS ENVIRONMENT}"
  printf '\n%s%s' "$C_PRIMARY" "$C_BOLD"
  cat <<'BANNER'
   ██████╗██╗   ██╗██████╗ ███████╗██████╗ ██████╗ ███████╗ ██████╗██╗  ██╗
  ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝██║ ██╔╝
  ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝██║  ██║█████╗  ██║     █████╔╝
  ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗██║  ██║██╔══╝  ██║     ██╔═██╗
  ╚██████╗   ██║   ██████╔╝███████╗██║  ██║██████╔╝███████╗╚██████╗██║  ██╗
   ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝
BANNER
  printf '%s' "$C_RESET"
  printf '  %s▸ %s%s — %s%s\n' "$C_PRIMARY" "$C_BOLD" "$title" "$sub" "$C_RESET"
  hline
}
section() { printf '\n%s┌─[ %s%s%s ]%s\n%s│%s\n' "$C_PRIMARY" "$C_BOLD" "$1" "$C_PRIMARY" "$C_RESET" "$C_MUTED" "$C_RESET"; }
section_end() { printf '%s└──%s\n' "$C_MUTED" "$C_RESET"; }
ok()   { printf '  %s%s %s%s\n' "$C_GREEN" "$SYM_OK" "$*" "$C_RESET"; }
err()  { printf '  %s%s %s%s\n' "$C_RED" "$SYM_ERROR" "$*" "$C_RESET" >&2; }
warn() { printf '  %s%s %s%s\n' "$C_AMBER" "$SYM_WARN" "$*" "$C_RESET"; }
info() { printf '  %s%s %s%s\n' "$C_PRIMARY" "$SYM_INFO" "$*" "$C_RESET"; }
online()  { printf '  %s%s %s%s\n' "$C_GREEN" "$SYM_ONLINE" "$*" "$C_RESET"; }
offline() { printf '  %s%s %s%s\n' "$C_GREY" "$SYM_OFFLINE" "$*" "$C_RESET"; }
kv() { printf '  %s├─ %-22s%s %s%s\n' "$C_MUTED" "$1" "$C_RESET" "$C_FG" "$2"; printf '%s' "$C_RESET"; }
# bar <value 0-100> [width]
bar() { local v=${1:-0} w=${2:-24} f e; (( v<0 )) && v=0; (( v>100 )) && v=100; f=$(( v*w/100 )); e=$(( w-f )); printf '%s' "$C_PRIMARY"; printf '▓%.0s' $(seq 1 "$f" 2>/dev/null) 2>/dev/null; printf '%s' "$C_MUTED"; printf '░%.0s' $(seq 1 "$e" 2>/dev/null) 2>/dev/null; printf '%s %3d%%' "$C_RESET" "$v"; }
spinner() { local pid=$1 msg="${2:-Working}" frames=('▖' '▘' '▝' '▗') i=0; while kill -0 "$pid" 2>/dev/null; do printf '\r  %s%s %s...%s' "$C_PRIMARY" "${frames[i%4]}" "$msg" "$C_RESET"; i=$((i+1)); sleep 0.15; done; printf '\r%*s\r' 60 ''; }
confirm() { local p="${1:-Continue?} [y/N] " r; [[ "${CYBERDECK_YES:-0}" == "1" ]] && return 0; printf '  %s%s %s%s' "$C_AMBER" "$SYM_WARN" "$p" "$C_RESET"; read -r r </dev/tty 2>/dev/null || return 1; [[ "$r" =~ ^[Yy] ]]; }
# table header: table_header "COL1" "COL2" ... ; rows with table_row
table_header() { printf '  %s┌' "$C_MUTED"; printf '─%.0s' $(seq 1 76); printf '┐%s\n  %s│%s ' "$C_RESET" "$C_MUTED" "$C_PRIMARY"; local c; for c in "$@"; do printf '%-18s' "$c"; done; printf '%s\n  %s├' "$C_RESET" "$C_MUTED"; printf '─%.0s' $(seq 1 76); printf '┤%s\n' "$C_RESET"; }
table_row() { printf '  %s│%s ' "$C_MUTED" "$C_RESET"; local c; for c in "$@"; do printf '%-18s' "$c"; done; printf '\n'; }
table_footer() { printf '  %s└' "$C_MUTED"; printf '─%.0s' $(seq 1 76); printf '┘%s\n' "$C_RESET"; }
legal_warning() {
  printf '\n  %s┌─[ AUTHORIZED USE ONLY ]────────────────────────────────────────┐%s\n' "$C_AMBER" "$C_RESET"
  printf '  %s│%s Only run this against systems you own or have explicit written   %s│%s\n' "$C_AMBER" "$C_RESET" "$C_AMBER" "$C_RESET"
  printf '  %s│%s permission to test. Unauthorized access is illegal.              %s│%s\n' "$C_AMBER" "$C_RESET" "$C_AMBER" "$C_RESET"
  printf '  %s└──────────────────────────────────────────────────────────────────┘%s\n\n' "$C_AMBER" "$C_RESET"
}
