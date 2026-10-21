#!/usr/bin/env bash
# polybar module: updates
N="$(pacman -Qu 2>/dev/null | wc -l)"; [ "$N" -gt 0 ] && echo "%{F#ffb000}⟳ $N updates%{F-}" || echo "%{F#00ff41}⟳ current%{F-}"
