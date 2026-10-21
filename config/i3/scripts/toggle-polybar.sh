#!/usr/bin/env bash
# toggle-polybar.sh — Super+b show/hide HUD bars (IPC, no restart flash)
if pgrep -x polybar >/dev/null; then polybar-msg cmd toggle 2>/dev/null || { pkill polybar; }; else ~/.config/polybar/launch.sh; fi
