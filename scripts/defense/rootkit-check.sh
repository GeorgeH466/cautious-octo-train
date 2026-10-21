#!/usr/bin/env bash
# rootkit-check.sh — Rootkit detection — rkhunter + chkrootkit + heuristics
# Cyberdeck-BlackArch | MIT | Part of scripts/defense/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "ROOTKIT-CHECK" "Rootkit detection — rkhunter + chkrootkit + heuristics"; cat <<USAGE
  USAGE: rootkit-check.sh [--full]
  Fast heuristics always run; --full adds rkhunter/chkrootkit deep scans.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "ROOTKIT-CHECK" "Rootkit detection — rkhunter + chkrootkit + heuristics"; :; log_msg "START args: $*"

  section "HEURISTIC CHECKS"
  warn_list=0
  for d in /dev/.udev /usr/share/.ice-unix /tmp/.ICE-unix/.X11; do [[ -e "$d" ]] && { warn "Suspicious hidden path exists: $d"; warn_list=1; }; done
  [[ -n "$(find / -maxdepth 4 -name '..*' -type d 2>/dev/null | grep -v proc | head -1)" ]] && warn "Hidden '..' style directories found (investigate)"
  awk -F: '$3==0 && $1!="root"{print "  [▲] extra UID-0 account: "$1}' /etc/passwd | tee -a "$LOG_FILE"
  awk -F: '$2==""{print "  [▲] passwordless account: "$1}' /etc/shadow 2>/dev/null || sudo awk -F: '$2==""{print "  [▲] passwordless account: "$1}' /etc/shadow 2>/dev/null
  ok "Heuristics done."
  if [[ "${1:-}" == "--full" ]]; then
    have rkhunter && { section "RKHUNTER"; sudo rkhunter --check --sk --rwo 2>/dev/null | tail -30 | sed 's/^/  /' | tee -a "$LOG_FILE"; } || warn "rkhunter missing (sudo pacman -S rkhunter; then: sudo rkhunter --propupd)"
    have chkrootkit && { section "CHKROOTKIT"; sudo chkrootkit -q 2>/dev/null | grep -vi 'not infected' | sed 's/^/  /' | tee -a "$LOG_FILE"; } || warn "chkrootkit missing (sudo pacman -S chkrootkit)"
  else info "Run with --full for rkhunter/chkrootkit scans."; fi
  log_msg "DONE"; }
main "$@"
