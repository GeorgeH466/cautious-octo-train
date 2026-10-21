#!/usr/bin/env bash
# launch.sh — (re)start the cyberdeck HUD bars on every monitor
killall -q polybar 2>/dev/null
while pgrep -x polybar >/dev/null; do sleep 0.3; done
if type xrandr >/dev/null 2>&1; then
  for m in $(xrandr --query | grep ' connected' | cut -d' ' -f1); do
    MONITOR="$m" polybar cyber-top >>~/.cyberdeck/logs/polybar.log 2>&1 &
    MONITOR="$m" polybar cyber-bottom >>~/.cyberdeck/logs/polybar.log 2>&1 &
  done
else
  polybar cyber-top >>~/.cyberdeck/logs/polybar.log 2>&1 &
  polybar cyber-bottom >>~/.cyberdeck/logs/polybar.log 2>&1 &
fi
