#!/usr/bin/env bash
# lib/colors.sh — Cyberdeck colour palette & theme loading
# Source this file; do not execute directly.
[[ -n "${_CYBERDECK_COLORS_LOADED:-}" ]] && return 0
_CYBERDECK_COLORS_LOADED=1

# Theme name: ghost|matrix|amber|blood  (env CYBERDECK_THEME or ~/.cyberdeck/theme)
CYBERDECK_THEME="${CYBERDECK_THEME:-}"
if [[ -z "$CYBERDECK_THEME" && -f "$HOME/.cyberdeck/theme" ]]; then
  CYBERDECK_THEME="$(head -n1 "$HOME/.cyberdeck/theme" | tr -d '[:space:]')"
fi
CYBERDECK_THEME="${CYBERDECK_THEME:-ghost}"

# Raw hex values (exported for other tools / polybar / conky)
case "$CYBERDECK_THEME" in
  matrix) HEX_BG="#0a0a0a"; HEX_FG="#c8ffd4"; HEX_PRIMARY="#00ff41"; HEX_SECONDARY="#00cc33"; HEX_ACCENT="#7dff9a"; HEX_WARN="#ffb000"; HEX_ALERT="#ff0040"; HEX_MUTED="#3d7a4d" ;;
  amber)  HEX_BG="#140e04"; HEX_FG="#ffe6b3"; HEX_PRIMARY="#ffb000"; HEX_SECONDARY="#ff8c00"; HEX_ACCENT="#ffd166"; HEX_WARN="#ffb000"; HEX_ALERT="#ff0040"; HEX_MUTED="#8a6d2f" ;;
  blood)  HEX_BG="#0a0002"; HEX_FG="#ffd6dd"; HEX_PRIMARY="#ff0040"; HEX_SECONDARY="#cc0033"; HEX_ACCENT="#ff6b8a"; HEX_WARN="#ffb000"; HEX_ALERT="#ff0040"; HEX_MUTED="#7a2d3d" ;;
  *) CYBERDECK_THEME="ghost"; HEX_BG="#0a0a0a"; HEX_FG="#e6ffff"; HEX_PRIMARY="#00fff5"; HEX_SECONDARY="#00b8b0"; HEX_ACCENT="#7dfff8"; HEX_WARN="#ffb000"; HEX_ALERT="#ff0040"; HEX_MUTED="#3d7a78" ;;
esac
export CYBERDECK_THEME HEX_BG HEX_FG HEX_PRIMARY HEX_SECONDARY HEX_ACCENT HEX_WARN HEX_ALERT HEX_MUTED

# ANSI helpers (disabled when not a TTY or NO_COLOR set)
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  _hex2ansi() { printf '\033[38;2;%d;%d;%dm' "0x${1:1:2}" "0x${1:3:2}" "0x${1:5:2}"; }
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'; C_ITALIC=$'\033[3m'; C_UNDER=$'\033[4m'; C_BLINK=$'\033[5m'
  C_PRIMARY="$(_hex2ansi "$HEX_PRIMARY")"; C_SECONDARY="$(_hex2ansi "$HEX_SECONDARY")"
  C_ACCENT="$(_hex2ansi "$HEX_ACCENT")"; C_FG="$(_hex2ansi "$HEX_FG")"
  C_MUTED="$(_hex2ansi "$HEX_MUTED")"
  C_CYAN=$'\033[38;2;0;255;245m'; C_GREEN=$'\033[38;2;0;255;65m'
  C_AMBER=$'\033[38;2;255;176;0m'; C_RED=$'\033[38;2;255;0;64m'
  C_WHITE=$'\033[97m'; C_GREY=$'\033[90m'; C_BLACK=$'\033[30m'
else
  C_RESET=""; C_BOLD=""; C_DIM=""; C_ITALIC=""; C_UNDER=""; C_BLINK=""
  C_PRIMARY=""; C_SECONDARY=""; C_ACCENT=""; C_FG=""; C_MUTED=""
  C_CYAN=""; C_GREEN=""; C_AMBER=""; C_RED=""; C_WHITE=""; C_GREY=""; C_BLACK=""
fi
export C_RESET C_BOLD C_DIM C_PRIMARY C_SECONDARY C_ACCENT C_FG C_MUTED C_CYAN C_GREEN C_AMBER C_RED C_WHITE C_GREY
# Status symbols
SYM_ACTIVE="[▓]"; SYM_INACTIVE="[░]"; SYM_ONLINE="[●]"; SYM_OFFLINE="[○]"
SYM_WARN="[▲]"; SYM_ERROR="[✖]"; SYM_OK="[✔]"; SYM_INFO="[◆]"; SYM_ARROW="▸"
export SYM_ACTIVE SYM_INACTIVE SYM_ONLINE SYM_OFFLINE SYM_WARN SYM_ERROR SYM_OK SYM_INFO SYM_ARROW
