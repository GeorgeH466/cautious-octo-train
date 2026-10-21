#!/usr/bin/env bash
# polybar module: cpu-bar
read -r _ u n s i w x y z _ < /proc/stat; T1=$((u+n+s+i+w+x+y+z)); I1=$((i+w)); sleep 1
read -r _ u n s i w x y z _ < /proc/stat; T2=$((u+n+s+i+w+x+y+z)); I2=$((i+w))
P=$(( 100*( (T2-T1)-(I2-I1) ) / ( (T2-T1)==0 ? 1 : (T2-T1) ) )); F=$((P*8/100)); B=""; for k in $(seq 1 8); do [ $k -le $F ] && B="${B}▓" || B="${B}░"; done
echo "CPU $B $P%"
