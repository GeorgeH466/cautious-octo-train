#!/usr/bin/env bash
# polybar module: mem-bar
P="$(free -m | awk '/Mem/{print int($3*100/$2)}')"; F=$((P*8/100)); B=""; for k in $(seq 1 8); do [ $k -le $F ] && B="${B}▓" || B="${B}░"; done; echo "RAM $B $P%"
