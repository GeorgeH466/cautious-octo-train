#!/usr/bin/env bash
# update-all.sh — Update system, AUR, pip tools & cyberdeck itself
# Cyberdeck-BlackArch | MIT | Part of scripts/system/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "UPDATE-ALL" "Update system, AUR, pip tools & cyberdeck itself"; cat <<USAGE
  USAGE: update-all.sh [--check] — pacman + yay/paru + pipx/pip + flatpak + git pull of cyberdeck.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "UPDATE-ALL" "Update system, AUR, pip tools & cyberdeck itself"; :; log_msg "START args: $*"

  if [[ "${1:-}" == "--check" ]]; then section "PENDING UPDATES"; pacman -Qu 2>/dev/null | head -40 | sed 's/^/  /'; info "$(pacman -Qu 2>/dev/null|wc -l) packages pending"; exit 0; fi
  confirm "Run full system update?" || exit 0
  sudo pacman -Syu || die "pacman update failed"
  for h in yay paru; do have $h && { $h -Sua --noconfirm; break; }; done
  have pipx && pipx upgrade-all 2>/dev/null; have flatpak && flatpak update -y 2>/dev/null
  for d in "$HOME/cyberdeck-blackarch" "$CYBERDECK_HOME/repo"; do [[ -d "$d/.git" ]] && (cd "$d" && git pull --ff-only && ok "cyberdeck repo updated — re-run ./install.sh --configs to refresh configs"); done
  ok "All updates complete."; log_msg "update-all done"
  log_msg "DONE"; }
main "$@"
