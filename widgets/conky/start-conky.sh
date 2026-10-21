#!/usr/bin/env bash
# start-conky.sh — launch all cyberdeck HUD widgets (kills previous instances)
killall -q conky 2>/dev/null; sleep 0.5
DIR="$HOME/.config/conky"; [[ -d "$DIR" ]] || DIR="$(cd "$(dirname "$0")" && pwd)"
for w in system-monitor network-monitor clock-hud threat-dashboard hex-rain; do
  [[ -f "$DIR/$w.conf" ]] && conky -q -c "$DIR/$w.conf" &
done
