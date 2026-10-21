#!/usr/bin/env bash
# lock-screen.sh — Sci-fi lock screen (i3lock-color with HUD ring & blur)
# Cyberdeck-BlackArch | MIT | Part of scripts/ui/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "LOCK-SCREEN" "Sci-fi lock screen (i3lock-color with HUD ring & blur)"; cat <<USAGE
  USAGE: lock-screen.sh [--blur|--pixel] — locks with themed i3lock; falls back to i3lock/xtrlock.
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "LOCK-SCREEN" "Sci-fi lock screen (i3lock-color with HUD ring & blur)"; log_msg "START args: $*"

  log_msg "screen locked"
  # Screenshot + blur background when tools allow
  local img=/tmp/cyberdeck-lock.png
  if have scrot && have convert; then scrot -o "$img" 2>/dev/null; [[ "${1:-}" == "--pixel" ]] && convert "$img" -scale 10% -scale 1000% "$img" || convert "$img" -blur 0x8 "$img" 2>/dev/null; fi
  local prim="${HEX_PRIMARY###}" alert="${HEX_ALERT###}"
  if have i3lock; then
    i3lock -i "$img" --inside-color=0a0a0add --ring-color="${prim}ff" --line-color=00000000 \
      --keyhl-color="${prim}ff" --bshl-color="${alert}ff" --separator-color=00000000 \
      --insidever-color=001a1add --ringver-color="${prim}ff" \
      --insidewrong-color=1a0008dd --ringwrong-color="${alert}ff" \
      --time-color="${prim}ff" --date-color=ffffffff --layout-color=ffffffff \
      --time-str="%H:%M:%S" --date-str="%Y-%m-%d // CYBERDECK LOCKED" \
      --verif-text="AUTHENTICATING…" --wrong-text="ACCESS DENIED" --noinput-text="AWAITING INPUT" \
      --clock --indicator --radius=120 --ring-width=2 2>/dev/null || i3lock -c 0a0a0a -i "$img" || i3lock -c 0a0a0a
  elif have slock; then slock
  elif have xtrlock; then xtrlock
  else die "No screen locker installed (sudo pacman -S i3lock-color)"; fi
  rm -f "$img"; log_msg "screen unlocked"
  log_msg "DONE"; }
main "$@"
