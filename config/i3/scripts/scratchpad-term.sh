#!/usr/bin/env bash
# scratchpad-term.sh — toggle floating scratchpad terminal (Super+`)
if ! pgrep -f 'alacritty.*scratchterm' >/dev/null; then alacritty -t scratchterm -e tmux new-session -A -s scratch & sleep 0.6; fi
i3-msg '[title="scratchterm"] scratchpad show' >/dev/null
