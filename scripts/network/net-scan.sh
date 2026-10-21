#!/usr/bin/env bash
# net-scan.sh — Full network scanner — nmap wrapper with formatted output
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
  cyber_banner "NET-SCAN" "Full network scanner — nmap wrapper with formatted output"
  cat <<USAGE
  USAGE: net-scan.sh [target] [quick|full|vuln|udp]
  target   IP / CIDR / hostname (default: local subnet)
  mode     quick=top100  full=all ports+versions+OS  vuln=NSE vuln  udp=top UDP
  Example: net-scan.sh 192.168.1.0/24 full
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(nmap:nmap); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "NET-SCAN" "Full network scanner — nmap wrapper with formatted output"
  legal_warning
  log_msg "START args: $*"

  local target="${1:-}" mode="${2:-quick}"
  [[ -z "$target" ]] && target="$(local_subnet)"
  [[ -z "$target" ]] && die "No target and could not detect local subnet."
  local out; out="$(outdir net-scan)"
  section "TARGET LOCK"; kv "Target" "$target"; kv "Mode" "$mode"; kv "Output" "$out"
  local args=()
  case "$mode" in
    quick) args=(-sV -T4 --top-ports 100) ;;
    full)  args=(-sS -sV -sC -O -p- -T4); [[ $EUID -ne 0 ]] && { warn "Full scan uses SYN/OS detection — sudo recommended"; } ;;
    vuln)  args=(-sV --script vuln -T4) ;;
    udp)   args=(-sU -sV --top-ports 50 -T4) ;;
    *) die "Unknown mode '$mode' (quick|full|vuln|udp)" ;;
  esac
  info "Launching nmap ${args[*]} $target"
  sudo nmap "${args[@]}" -oA "$out/scan" "$target" 2>&1 | tee -a "$LOG_FILE" || nmap "${args[@]}" -oA "$out/scan" "$target" | tee -a "$LOG_FILE"
  ok "Results saved: $out/scan.{nmap,xml,gnmap}"; section_end
  log_msg "DONE rc=$?"
}
main "$@"
