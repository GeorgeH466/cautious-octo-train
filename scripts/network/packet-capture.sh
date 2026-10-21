#!/usr/bin/env bash
# packet-capture.sh — tcpdump/tshark capture wrapper with BPF filters
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
  cyber_banner "PACKET-CAPTURE" "tcpdump/tshark capture wrapper with BPF filters"
  cat <<USAGE
  USAGE: packet-capture.sh [interface] [bpf-filter] [count]
  Example: packet-capture.sh eth0 'port 443' 200
  Saves .pcap to ~/.cyberdeck/captures/ and prints a live summary.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(tcpdump:tcpdump); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "PACKET-CAPTURE" "tcpdump/tshark capture wrapper with BPF filters"
  legal_warning
  log_msg "START args: $*"

  local iface="${1:-$(default_iface)}" filter="${2:-}" count="${3:-100}"
  local file="$CYBERDECK_HOME/captures/cap-$(timestamp).pcap"
  section "PACKET CAPTURE"; kv "Interface" "$iface"; kv "Filter" "${filter:-<all>}"; kv "Packets" "$count"; kv "File" "$file"
  info "Capturing… (Ctrl-C stops early)"; log_msg "capture iface=$iface filter=$filter file=$file"
  # shellcheck disable=SC2086
  sudo tcpdump -i "$iface" -c "$count" -nn -l $filter -w "$file" 2>&1 | grep -v '^tcpdump:' | tee -a "$LOG_FILE" || true
  sudo chown "$USER" "$file" 2>/dev/null || true
  ok "Saved $file"; have tshark && { section "PROTOCOL HIERARCHY"; tshark -r "$file" -q -z io,phs 2>/dev/null | head -30 | sed 's/^/  /'; }
  log_msg "DONE rc=$?"
}
main "$@"
