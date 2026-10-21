#!/usr/bin/env bash
# encrypt-file.sh — File encryption — age (preferred) or GPG symmetric/asymmetric
# Cyberdeck-BlackArch | MIT | Part of scripts/crypto/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "ENCRYPT-FILE" "File encryption — age (preferred) or GPG symmetric/asymmetric"; cat <<USAGE
  USAGE: encrypt-file.sh <file> [--to <gpg-key-id>|--age-key <pubkey>] [--shred]
  Default: passphrase encryption (age if present else gpg AES256). --shred wipes the original.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "ENCRYPT-FILE" "File encryption — age (preferred) or GPG symmetric/asymmetric"; :; log_msg "START args: $*"

  local f="${1:-}"; [[ -f "$f" ]] || die "Usage: encrypt-file <file> [--to KEY] [--shred]"
  local out
  if [[ "${2:-}" == "--to" ]]; then out="$f.gpg"; gpg --encrypt --armor --recipient "${3:?key id}" -o "$out" "$f"
  elif [[ "${2:-}" == "--age-key" ]]; then out="$f.age"; age -r "${3:?age pubkey}" -o "$out" "$f"
  elif have age; then out="$f.age"; age --passphrase -o "$out" "$f"
  elif have gpg; then out="$f.gpg"; gpg --symmetric --cipher-algo AES256 -o "$out" "$f"
  else die "Install age or gnupg"; fi
  log_msg "encrypt $f -> $out"; ok "Encrypted → $out"
  [[ "$*" == *"--shred"* ]] && { shred -u "$f" 2>/dev/null || rm -P "$f" 2>/dev/null || rm "$f"; warn "Original shredded."; }
  log_msg "DONE"; }
main "$@"
