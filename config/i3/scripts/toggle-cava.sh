#!/usr/bin/env bash
# toggle-cava.sh — Super+m audio visualizer popup
if pgrep -x cava >/dev/null; then pkill cava; else alacritty -t cava -e cava & fi
