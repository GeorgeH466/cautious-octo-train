#!/usr/bin/env bash
# status-board.sh — Full status board — system, network, threat posture at a glance
# Cyberdeck-BlackArch | MIT | Part of scripts/cyberdeck/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "STATUS-BOARD" "Full status board — system, network, threat posture at a glance"; cat <<USAGE
  USAGE: status-board.sh [--watch [secs]] — one-screen SITREP; --watch refreshes.
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "STATUS-BOARD" "Full status board — system, network, threat posture at a glance"; log_msg "START args: $*"

  render() {
    section "SYSTEM"; kv "Host / OS" "$(hostname) · $(grep -oP 'PRETTY_NAME="\K[^"]+' /etc/os-release 2>/dev/null)"; kv "Kernel / Uptime" "$(uname -r) · $(uptime -p|sed 's/up //')"
    printf '  ├─ %-22s ' "CPU"; bar "$(top -bn1 2>/dev/null|awk -F, '/Cpu/{print int(100-$4)}')"; echo
    printf '  ├─ %-22s ' "RAM"; bar "$(free -m|awk '/Mem/{print int($3*100/$2)}')"; echo
    printf '  ├─ %-22s ' "Disk /"; bar "$(df / --output=pcent|tail -1|tr -dc 0-9)"; echo
    kv "Load" "$(cut -d' ' -f1-3 /proc/loadavg)"; kv "Processes" "$(ps -e --no-headers|wc -l) running"
    section "NETWORK"; kv "Interface" "$(default_iface)"; kv "Local / Gateway" "$(local_ip) / $(gateway_ip)"; kv "Public IP" "$(public_ip)"; kv "DNS" "$(grep -m1 nameserver /etc/resolv.conf|awk '{print $2}')"; kv "Established conns" "$(ss -tun state established 2>/dev/null|tail -n +2|wc -l)"; kv "Listening ports" "$(ss -tlnp 2>/dev/null|tail -n +2|awk '{print $4}'|grep -oE '[0-9]+$'|sort -un|paste -sd, -)"
    section "THREAT POSTURE"
    local threat="LOW" tc="$C_GREEN"; local fails; fails="$(journalctl --since '-1h' -u sshd --no-pager 2>/dev/null|grep -ci 'failed password')"
    (( fails > 50 )) && { threat="HIGH — SSH brute force?"; tc="$C_RED"; }; (( fails > 5 && fails <= 50 )) && { threat="ELEVATED"; tc="$C_AMBER"; }
    printf '  %s%s THREAT LEVEL: %s%s   (failed SSH logins last hour: %s)\n' "$tc" "$SYM_WARN" "$threat" "$C_RESET" "$fails"
    kv "Tor / Fail2ban" "$(systemctl is-active tor 2>/dev/null) / $(systemctl is-active fail2ban 2>/dev/null)"; kv "Pending updates" "$(pacman -Qu 2>/dev/null|wc -l)"; kv "Theme" "$CYBERDECK_THEME"
  }
  if [[ "${1:-}" == "--watch" ]]; then while true; do printf '\033[H\033[2J'; cyber_banner "STATUS-BOARD" "live SITREP — q quits"; render; read -rt "${2:-5}" -n1 k </dev/tty 2>/dev/null; [[ "$k" == q ]] && break; done
  else render; fi
  log_msg "DONE"; }
main "$@"
