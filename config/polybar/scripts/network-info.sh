#!/usr/bin/env bash
# polybar module: network-info
IFACE="$(ip route show default 2>/dev/null | awk 'NR==1{print $5}')"; IP="$(ip -4 -o addr show "$IFACE" 2>/dev/null | awk '{split($4,a,"/");print a[1]}')"
[ -n "$IP" ] && echo "◈ $IFACE $IP" || echo "%{F#ff0040}◈ OFFLINE%{F-}"
