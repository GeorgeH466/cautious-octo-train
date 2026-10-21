#!/usr/bin/env bash
# theme-switcher.sh — Hot-swap colour themes — Ghost / Matrix / Amber / Blood
# Cyberdeck-BlackArch | MIT | Part of scripts/ui/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "THEME-SWITCHER" "Hot-swap colour themes — Ghost / Matrix / Amber / Blood"; cat <<USAGE
  USAGE: theme-switcher.sh [ghost|matrix|amber|blood|--list]
  No args: interactive picker (rofi in X, menu in terminal). Re-renders polybar/rofi/dunst/alacritty/i3 accents and restarts bars.
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "THEME-SWITCHER" "Hot-swap colour themes — Ghost / Matrix / Amber / Blood"; log_msg "START args: $*"

  local theme="${1:-}"
  if [[ "$theme" == "--list" || -z "$theme" ]]; then section "THEMES"; for t in ghost matrix amber blood; do [[ "$t" == "$CYBERDECK_THEME" ]] && printf '  %s %s (active)\n' "$SYM_ACTIVE" "$t" || printf '  %s %s\n' "$SYM_INACTIVE" "$t"; done; fi
  if [[ -z "$theme" ]]; then
    if [[ -n "${DISPLAY:-}" ]] && have rofi; then theme="$(printf 'ghost\nmatrix\namber\nblood' | rofi -dmenu -p '◢ THEME')"
    else printf '  Select theme [ghost/matrix/amber/blood]: '; read -r theme </dev/tty; fi
  fi
  case "$theme" in ghost|matrix|amber|blood) ;; *) die "Unknown theme '$theme'";; esac
  echo "$theme" >"$CYBERDECK_HOME/theme"; export CYBERDECK_THEME="$theme"
  # Re-source palette for the new theme
  _CYBERDECK_COLORS_LOADED=""; source "$LIB/colors.sh"
  # Xresources-style include used by polybar/alacritty templates
  printf 'primary=%s\nsecondary=%s\naccent=%s\nbackground=%s\nforeground=%s\nmuted=%s\nalert=%s\n' "$HEX_PRIMARY" "$HEX_SECONDARY" "$HEX_ACCENT" "$HEX_BG" "$HEX_FG" "$HEX_MUTED" "$HEX_ALERT" >"$CYBERDECK_HOME/current-theme.env"
  # Patch alacritty primary colours if config present
  local ala="$HOME/.config/alacritty/alacritty.toml"
  [[ -f "$ala" ]] && sed -i -E "s/^(background = ).*/\1\"$HEX_BG\"/; s/^(foreground = ).*/\1\"$HEX_FG\"/; s/^(cursor = ).*/\1\"$HEX_PRIMARY\"/" "$ala" 2>/dev/null
  # Restart polybar + dunst + conky to pick up theme
  pkill -USR1 polybar 2>/dev/null || { pkill polybar 2>/dev/null; [[ -x "$HOME/.config/polybar/launch.sh" ]] && "$HOME/.config/polybar/launch.sh" & }
  pkill dunst 2>/dev/null; have dunst && (dunst &)
  have i3-msg && i3-msg reload >/dev/null 2>&1
  have notify-send && notify-send "Cyberdeck" "Theme switched → $theme"
  ok "Theme '$theme' active ($HEX_PRIMARY on $HEX_BG). New terminals pick it up automatically."
  log_msg "DONE"; }
main "$@"
