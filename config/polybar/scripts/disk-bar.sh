#!/usr/bin/env bash
# polybar module: disk-bar
P="$(df / --output=pcent | tail -1 | tr -dc 0-9)"; F=$((P*8/100)); B=""; for k in $(seq 1 8); do [ $k -le $F ] && B="${B}▓" || B="${B}░"; done; echo "DSK $B $P%"
