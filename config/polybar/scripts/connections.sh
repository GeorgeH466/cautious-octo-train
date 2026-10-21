#!/usr/bin/env bash
# polybar module: connections
echo "⬢ $(ss -tun state established 2>/dev/null | tail -n +2 | wc -l) conn"
