#!/usr/bin/env bash
# polybar module: threat-level
FAILS="$(journalctl --since '-1h' -u sshd --no-pager 2>/dev/null | grep -ci 'failed password')"
if [ "${FAILS:-0}" -gt 50 ]; then echo "%{F#ff0040}THREAT:HIGH%{F-}"; elif [ "${FAILS:-0}" -gt 5 ]; then echo "%{F#ffb000}THREAT:ELEV%{F-}"; else echo "%{F#00ff41}THREAT:LOW%{F-}"; fi
