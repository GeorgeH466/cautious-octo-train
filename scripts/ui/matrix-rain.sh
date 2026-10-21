#!/usr/bin/env bash
# matrix-rain.sh — Matrix digital rain for the terminal (cmatrix / unimatrix / built-in)
# Cyberdeck-BlackArch | MIT | Part of scripts/ui/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "MATRIX-RAIN" "Matrix digital rain for the terminal (cmatrix / unimatrix / built-in)"; cat <<USAGE
  USAGE: matrix-rain.sh [--color green|cyan|amber|red] — any key exits. Uses cmatrix if present, else pure-bash rain.
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "MATRIX-RAIN" "Matrix digital rain for the terminal (cmatrix / unimatrix / built-in)"; log_msg "START args: $*"

  local color=green; [[ "${1:-}" == "--color" ]] && color="${2:-green}"
  if have unimatrix; then unimatrix -c "$color" -s 95; exit 0; fi
  if have cmatrix; then case "$color" in cyan) cmatrix -C cyan;; amber) cmatrix -C yellow;; red) cmatrix -C red;; *) cmatrix -C green;; esac; exit 0; fi
  # Pure-bash fallback rain
  printf '\033[?25l'; trap 'printf "\033[?25h\033[0m"; exit 0' INT TERM
  local -a drops; local cols=$(tput cols) lines=$(tput lines) chars=("ｱ" "ｲ" "ｳ" "ｴ" "ｵ" "ｶ" "ｷ" "ｸ" "ｹ" "ｺ" "0" "1" "2" "7" "ﾊ" "ﾐ" "ﾋ" "ｰ" "ｳ" "ｼ")
  for ((i=0;i<cols;i++)); do drops[i]=$((RANDOM%lines)); done
  while true; do
    for ((c=0;c<cols;c+=2)); do
      (( RANDOM%3 )) && continue
      drops[c]=$(( (drops[c]+1)%lines ))
      printf '\033[%d;%dH%s%s%s' "${drops[c]}" "$((c+1))" "$C_GREEN" "${chars[RANDOM%${#chars[@]}]}" "$C_RESET"
      local trail=$(( drops[c]-6 )); (( trail>0 )) && printf '\033[%d;%dH ' "$trail" "$((c+1))"
    done
    read -rt 0.05 -n1 k </dev/tty 2>/dev/null && break
  done
  printf '\033[?25h\033[0m\n' 
  log_msg "DONE"; }
main "$@"
