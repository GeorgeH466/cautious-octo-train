#!/usr/bin/env bash
# polybar module: tor-status
if ss -tln 2>/dev/null | grep -q ':9050'; then echo "%{F#00ff41}TOR●%{F-}"; else echo "%{F#3d7a78}TOR○%{F-}"; fi
