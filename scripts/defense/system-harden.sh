#!/usr/bin/env bash
# system-harden.sh — Interactive system hardening checklist & applier
# Cyberdeck-BlackArch | MIT | Part of scripts/defense/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "SYSTEM-HARDEN" "Interactive system hardening checklist & applier"; cat <<USAGE
  USAGE: system-harden.sh [--audit|--apply]
  --audit (default): scores SSH, firewall, updates, permissions, kernel sysctls.
  --apply: interactively applies safe fixes (each one confirmed).
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "SYSTEM-HARDEN" "Interactive system hardening checklist & applier"; :; log_msg "START args: $*"

  local score=0 total=8
  section "HARDENING AUDIT"
  chk() { if eval "$2" >/dev/null 2>&1; then ok "$1"; score=$((score+1)); else warn "$1 — NOT SET"; fi; }
  chk "SSH root login disabled" "grep -qE '^PermitRootLogin (no|prohibit)' /etc/ssh/sshd_config"
  chk "SSH password auth off (keys only)" "grep -qE '^PasswordAuthentication no' /etc/ssh/sshd_config"
  chk "Firewall active" "ufw status 2>/dev/null|grep -q active || sudo nft list ruleset 2>/dev/null|grep -q chain || sudo iptables -L INPUT -n|grep -q DROP"
  chk "fail2ban active" "systemctl is-active --quiet fail2ban"
  chk "ASLR fully on (randomize_va_space=2)" "[[ \$(cat /proc/sys/kernel/randomize_va_space) == 2 ]]"
  chk "Core dumps restricted" "[[ \$(cat /proc/sys/fs/suid_dumpable) == 0 ]]"
  chk "No world-writable files in /etc" "[[ -z \$(find /etc -maxdepth 2 -perm -0002 -type f 2>/dev/null|head -1) ]]"
  chk "System up to date (pacman)" "[[ -z \$(pacman -Qu 2>/dev/null|head -1) ]]"
  printf '\n  %sSCORE %d/%d %s' "$C_BOLD" "$score" "$total" "$C_RESET"; bar $((score*100/total)); echo
  have lynis && info "Deep audit: sudo lynis audit system" || info "Tip: sudo pacman -S lynis for a full audit"
  if [[ "${1:-}" == "--apply" ]]; then section "APPLY FIXES (each confirmed)"
    confirm "Disable SSH root login + password auth? (keys must work first!)" && { sudo sed -i -E 's/^#?PermitRootLogin.*/PermitRootLogin no/;s/^#?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config; sudo systemctl reload sshd 2>/dev/null; ok "sshd hardened"; }
    confirm "Apply safe kernel sysctls (syncookies, rp_filter, icmp ignore)?" && { printf 'net.ipv4.tcp_syncookies=1\nnet.ipv4.conf.all.rp_filter=1\nnet.ipv4.icmp_echo_ignore_broadcasts=1\nkernel.kptr_restrict=2\n' | sudo tee /etc/sysctl.d/99-cyberdeck.conf >/dev/null; sudo sysctl --system >/dev/null; ok "sysctls applied"; }
    confirm "Enable & start fail2ban (installs if needed)?" && { sudo pacman -S --needed --noconfirm fail2ban; sudo systemctl enable --now fail2ban; ok "fail2ban on"; }
  fi; log_msg "harden score=$score/$total mode=${1:-audit}"
  log_msg "DONE"; }
main "$@"
