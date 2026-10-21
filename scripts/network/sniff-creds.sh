#!/usr/bin/env bash
# sniff-creds.sh — Cleartext credential spotting — EDUCATIONAL (own traffic only)
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
  cyber_banner "SNIFF-CREDS" "Cleartext credential spotting — EDUCATIONAL (own traffic only)"
  cat <<USAGE
  USAGE: sniff-creds.sh [interface] [pcap-file]
  Highlights cleartext protocols (FTP/Telnet/HTTP-basic) in live traffic or a pcap.
  Demonstrates WHY cleartext protocols must die. Own/authorised traffic ONLY.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(tshark:wireshark-cli); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "SNIFF-CREDS" "Cleartext credential spotting — EDUCATIONAL (own traffic only)"
  legal_warning
  log_msg "START args: $*"

  warn "Capturing other people's credentials is illegal. Lab/own traffic only."
  confirm "Confirm authorised/lab use?" || die "Aborted."
  section "CLEARTEXT CREDENTIAL WATCH"
  if [[ -n "${2:-}" ]]; then tshark -r "$2" -Y 'ftp.request.command matches "USER|PASS" or http.authorization or telnet' -T fields -e ip.src -e ftp.request.arg -e http.authorization 2>/dev/null | sed 's/^/  [▲] /' | tee -a "$LOG_FILE"
  else info "Listening on ${1:-$(default_iface)} for FTP/Telnet/HTTP-basic… Ctrl-C to stop"
    sudo tshark -i "${1:-$(default_iface)}" -l -Y 'ftp.request.command matches "USER|PASS" or http.authorization' -T fields -e ip.src -e ip.dst -e ftp.request.arg -e http.authorization 2>/dev/null | sed 's/^/  [▲] /' | tee -a "$LOG_FILE"; fi
  log_msg "DONE rc=$?"
}
main "$@"
