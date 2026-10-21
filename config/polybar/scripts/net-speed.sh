#!/usr/bin/env bash
# polybar module: net-speed
IFACE="$(ip route show default 2>/dev/null | awk 'NR==1{print $5}')"; [ -z "$IFACE" ] && { echo "▼— ▲—"; exit 0; }
RX1=$(cat /sys/class/net/$IFACE/statistics/rx_bytes); TX1=$(cat /sys/class/net/$IFACE/statistics/tx_bytes); sleep 1
RX2=$(cat /sys/class/net/$IFACE/statistics/rx_bytes); TX2=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
awk -v r=$((RX2-RX1)) -v t=$((TX2-TX1)) 'BEGIN{printf "▼ %.0fK ▲ %.0fK\n", r/1024, t/1024}'
while true; do RX1=$RX2; TX1=$TX2; sleep 1; RX2=$(cat /sys/class/net/$IFACE/statistics/rx_bytes); TX2=$(cat /sys/class/net/$IFACE/statistics/tx_bytes); awk -v r=$((RX2-RX1)) -v t=$((TX2-TX1)) 'BEGIN{printf "▼ %.0fK ▲ %.0fK\n", r/1024, t/1024}'; done
