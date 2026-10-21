#!/usr/bin/env bash
# boot-splash.sh — Cyberdeck 'system initialization' boot splash animation
# Cyberdeck-BlackArch | MIT | Part of scripts/ui/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "BOOT-SPLASH" "Cyberdeck 'system initialization' boot splash animation"; cat <<USAGE
  USAGE: boot-splash.sh [--fast] — plays the init sequence (also sourced by MOTD on first shell of the day).
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "BOOT-SPLASH" "Cyberdeck 'system initialization' boot splash animation"; log_msg "START args: $*"

  local delay=0.12; [[ "${1:-}" == "--fast" ]] && delay=0.02
  cyber_banner "SYSTEM INITIALIZATION" "CYBERDECK OS // BLACKARCH CORE"
  step() { printf '  %s[%-28s]%s ' "$C_MUTED" "$1" "$C_RESET"; sleep "$delay"; printf '%s%s%s\n' "$C_GREEN" "${2:-OK}" "$C_RESET"; }
  step "KERNEL" "$(uname -r)"
  step "HOST" "$(hostname)"
  step "DISPLAY / WM" "${XDG_CURRENT_DESKTOP:-i3-gaps}"
  step "NETWORK INTERFACE" "$(default_iface) $(local_ip)"
  step "GATEWAY" "$(gateway_ip)"
  step "ENCRYPTION MODULES" "GPG+AGE LOADED"
  step "TOOL REGISTRY" "$(find "$HOME/.cyberdeck/bin" "$_SDIR/.." -name '*.sh' 2>/dev/null | wc -l) modules"
  step "THEME ENGINE" "$CYBERDECK_THEME / $HEX_PRIMARY"
  step "FIREWALL" "$(systemctl is-active ufw 2>/dev/null || echo check)"
  printf '\n  '; bar 100 40; printf '\n  %s%s ALL SYSTEMS NOMINAL — DECK ONLINE%s\n\n' "$C_GREEN" "$SYM_OK" "$C_RESET"
  log_msg "DONE"; }
main "$@"
