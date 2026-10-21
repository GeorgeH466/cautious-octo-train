#!/usr/bin/env bash
# decrypt-file.sh — File decryption — age / GPG auto-detect
# Cyberdeck-BlackArch | MIT | Part of scripts/crypto/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "DECRYPT-FILE" "File decryption — age / GPG auto-detect"; cat <<USAGE
  USAGE: decrypt-file.sh <file.age|file.gpg|file.asc> [output]
  Output defaults to the filename with the crypto suffix stripped.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "DECRYPT-FILE" "File decryption — age / GPG auto-detect"; :; log_msg "START args: $*"

  local f="${1:-}"; [[ -f "$f" ]] || die "Usage: decrypt-file <encrypted-file> [output]"
  local out="${2:-${f%.age}}"; out="${out%.gpg}"; out="${out%.asc}"; [[ "$out" == "$f" ]] && out="$f.dec"
  case "$f" in *.age) have age || die "age required"; age --decrypt -o "$out" "$f";; *.gpg|*.asc|*.pgp) have gpg || die "gpg required"; gpg --decrypt -o "$out" "$f";; *) die "Unknown suffix — expected .age/.gpg/.asc";; esac
  log_msg "decrypt $f -> $out"; ok "Decrypted → $out"
  log_msg "DONE"; }
main "$@"
