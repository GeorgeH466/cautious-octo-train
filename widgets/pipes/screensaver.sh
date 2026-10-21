#!/usr/bin/env bash
# screensaver.sh — random terminal screensaver picker
set -uo pipefail
CHOICE=$((RANDOM % 3))
command -v pipes.sh >/dev/null && [[ $CHOICE -eq 0 ]] && exec pipes.sh -t 3 -f 60
command -v cbonsai >/dev/null && [[ $CHOICE -eq 1 ]] && exec cbonsai -l -i
exec matrix-rain
