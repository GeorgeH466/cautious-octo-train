#!/usr/bin/env bash
# tor-manager.sh — Tor service manager with circuit / exit display
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
  cyber_banner "TOR-MANAGER" "Tor service manager with circuit / exit display"
  cat <<USAGE
  USAGE: tor-manager.sh <start|stop|status|newid|check>
  check → verifies Tor via check.torproject.org and shows exit IP.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# no external deps beyond coreutils
main() {
  cyber_banner "TOR-MANAGER" "Tor service manager with circuit / exit display"
  :
  log_msg "START args: $*"

  local action="${1:-status}"
  case "$action" in
    start) sudo systemctl start tor && ok "Tor started (SOCKS 127.0.0.1:9050)" || warn "systemd start failed — try: tor &" ;;
    stop) sudo systemctl stop tor; ok "Tor stopped." ;;
    status) systemctl is-active tor 2>/dev/null | sed 's/^/  service: /'; ss -tlnp 2>/dev/null | grep 9050 | sed 's/^/  /'; "$0" check ;;
    newid) have tor || true; printf 'AUTHENTICATE ""\r\nSIGNAL NEWNYM\r\nQUIT\r\n' | nc -w3 127.0.0.1 9051 >/dev/null 2>&1 && ok "New circuit requested." || warn "Control port 9051 not reachable (enable ControlPort in torrc)." ;;
    check) local r; r="$(curl -fsS --socks5-hostname 127.0.0.1:9050 --max-time 15 https://check.torproject.org/api/ip 2>/dev/null)"; if [[ "$r" == *'"IsTor": true'* ]]; then ok "Tor ACTIVE — exit: $(echo "$r"|grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'|head -1)"; else warn "Tor not routing (service down or no circuit yet)."; fi ;;
    *) die "Usage: tor-manager start|stop|status|newid|check" ;;
  esac; log_msg "tor $action"
  log_msg "DONE rc=$?"
}
main "$@"
