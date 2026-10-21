#!/usr/bin/env bash
# system-info.sh — Detailed system information report
# Cyberdeck-BlackArch | MIT | Part of scripts/system/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "SYSTEM-INFO" "Detailed system information report"; cat <<USAGE
  USAGE: system-info.sh [--save] — OS, kernel, CPU, RAM, disk, GPU, network, security posture.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "SYSTEM-INFO" "Detailed system information report"; :; log_msg "START args: $*"

  section "OPERATING SYSTEM"; kv "OS" "$(grep PRETTY_NAME /etc/os-release 2>/dev/null|cut -d'"' -f2)"; kv "Kernel" "$(uname -r)"; kv "Hostname" "$(hostname)"; kv "Uptime" "$(uptime -p)"; kv "Shell" "$SHELL"; kv "User" "$(whoami) (uid $(id -u))"
  section "RESOURCES"
  local cpu_p; cpu_p="$(top -bn1 2>/dev/null|awk -F, '/Cpu/{print 100-$4+0}'|cut -d. -f1)"; printf '  ├─ %-22s ' "CPU"; bar "${cpu_p:-0}"; echo
  read -r _ mt mu <<<"$(free -m|awk '/Mem/{print $1,$2,$3}')"; printf '  ├─ %-22s ' "RAM ${mu}/${mt}MB"; bar $(( mu*100/(mt==0?1:mt) )); echo
  df -h / 2>/dev/null | awk 'NR==2{printf "  ├─ Disk /                %s / %s (%s)\n",$3,$2,$5}'
  section "NETWORK"; kv "Interface" "$(default_iface)"; kv "Local IP" "$(local_ip)"; kv "Gateway" "$(gateway_ip)"; kv "Public IP" "$(public_ip)"
  section "SECURITY"; kv "Tor" "$(systemctl is-active tor 2>/dev/null||echo n/a)"; kv "Firewall (ufw)" "$(ufw status 2>/dev/null|head -1||echo n/a)"; kv "Fail2ban" "$(systemctl is-active fail2ban 2>/dev/null||echo n/a)"; kv "Pending updates" "$(pacman -Qu 2>/dev/null|wc -l)"
  [[ "${1:-}" == "--save" ]] && { local f="$CYBERDECK_HOME/reports/sysinfo-$(timestamp).txt"; "$0" | strip_ansi >"$f"; ok "Saved $f"; }
  log_msg "DONE"; }
main "$@"
