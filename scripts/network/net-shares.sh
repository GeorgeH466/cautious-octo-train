#!/usr/bin/env bash
# net-shares.sh — SMB / NFS network share enumerator
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
  cyber_banner "NET-SHARES" "SMB / NFS network share enumerator"
  cat <<USAGE
  USAGE: net-shares.sh <target> [user] [password]
  Enumerates SMB shares (smbclient/enum4linux) and NFS exports (showmount).
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(nmap:nmap); check_deps "${DEPS[@]}" || exit 1
main() {
  cyber_banner "NET-SHARES" "SMB / NFS network share enumerator"
  legal_warning
  log_msg "START args: $*"

  local target="${1:-}"; [[ -z "$target" ]] && die "Usage: net-shares.sh <target> [user] [pass]"
  local out; out="$(outdir net-shares)"
  section "SMB SHARES — $target"
  if have smbclient; then smbclient -L "$target" -N 2>/dev/null | tee "$out/smb.txt" | sed 's/^/  /' || smbclient -L "$target" -U "${2:-guest}%${3:-}" 2>/dev/null | sed 's/^/  /'; else warn "smbclient missing (sudo pacman -S smbclient)"; fi
  have enum4linux && enum4linux -a "$target" 2>/dev/null | tee "$out/enum4linux.txt" | head -40 | sed 's/^/  /'
  section "NFS EXPORTS"; have showmount && showmount -e "$target" 2>/dev/null | sed 's/^/  /' || nmap -p 2049 --script nfs-showmount "$target" | sed 's/^/  /'
  nmap -p 445 --script smb-enum-shares,smb-os-discovery "$target" 2>/dev/null | sed -n '/PORT/,$p' | sed 's/^/  /' | tee -a "$out/smb.txt"
  ok "Saved to $out"
  log_msg "DONE rc=$?"
}
main "$@"
