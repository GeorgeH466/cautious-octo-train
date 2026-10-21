#!/usr/bin/env bash
# polybar module: vpn-status
if ip link show type wireguard 2>/dev/null | grep -q '^[0-9]'; then echo "%{F#00ff41}VPN●%{F-}"; elif pgrep -x openvpn >/dev/null; then echo "%{F#00ff41}VPN●%{F-}"; else echo "%{F#3d7a78}VPN○%{F-}"; fi
