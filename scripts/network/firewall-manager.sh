#!/usr/bin/env bash
# firewall-manager.sh — iptables / nftables / ufw rule manager
# Cyberdeck-BlackArch | MIT | Part of scripts/network/
set -uo pipefail
# ── locate shared libraries ──────────────────────────────────────────────
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do
  [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }
done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh";
else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi

usage() {
  cyber_banner "FIREWALL-MANAGER" "iptables / nftables / ufw rule manager"
  cat <<USAGE
  USAGE: firewall-manager.sh <status|list|allow <port>|deny <port>|block-ip <ip>|unblock-ip <ip>|panic|reset>
  Uses ufw when enabled, otherwise nftables/iptables. 'panic' drops ALL traffic.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# no external deps beyond coreutils
main() {
  cyber_banner "FIREWALL-MANAGER" "iptables / nftables / ufw rule manager"
  :
  log_msg "START args: $*"

  local action="${1:-status}" arg="${2:-}" backend="iptables"; have nft && backend="nft"; (have ufw && ufw status 2>/dev/null | grep -q active) && backend="ufw"
  kv "Backend" "$backend"
  case "$action" in
    status|list) case "$backend" in ufw) sudo ufw status numbered;; nft) sudo nft list ruleset;; *) sudo iptables -L -n -v --line-numbers;; esac | head -60 | sed 's/^/  /' ;;
    allow) [[ -z "$arg" ]] && die "port required"; case "$backend" in ufw) sudo ufw allow "$arg";; nft) sudo nft add rule inet filter input tcp dport "$arg" accept 2>/dev/null || sudo iptables -A INPUT -p tcp --dport "$arg" -j ACCEPT;; *) sudo iptables -A INPUT -p tcp --dport "$arg" -j ACCEPT;; esac; ok "Allowed port $arg" ;;
    deny) [[ -z "$arg" ]] && die "port required"; case "$backend" in ufw) sudo ufw deny "$arg";; *) sudo iptables -A INPUT -p tcp --dport "$arg" -j DROP;; esac; ok "Denied port $arg" ;;
    block-ip) is_ip "$arg" || die "valid IP required"; case "$backend" in ufw) sudo ufw deny from "$arg";; *) sudo iptables -A INPUT -s "$arg" -j DROP;; esac; ok "Blocked $arg" ;;
    unblock-ip) case "$backend" in ufw) sudo ufw delete deny from "$arg";; *) sudo iptables -D INPUT -s "$arg" -j DROP;; esac; ok "Unblocked $arg" ;;
    panic) confirm "DROP ALL network traffic?" || exit 1; sudo iptables -P INPUT DROP; sudo iptables -P OUTPUT DROP; sudo iptables -P FORWARD DROP; warn "PANIC MODE — all traffic dropped. Undo: firewall-manager reset" ;;
    reset) confirm "Flush rules & set ACCEPT policies?" || exit 1; sudo iptables -P INPUT ACCEPT; sudo iptables -P OUTPUT ACCEPT; sudo iptables -P FORWARD ACCEPT; sudo iptables -F; ok "Firewall reset." ;;
    *) die "Usage: firewall-manager status|allow|deny|block-ip|unblock-ip|panic|reset" ;;
  esac; log_msg "fw $action $arg backend=$backend"
  log_msg "DONE rc=$?"
}
main "$@"
