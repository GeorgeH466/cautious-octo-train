#!/usr/bin/env bash
# hash-file.sh — File hashing — MD5/SHA1/SHA256/SHA512/BLAKE2 + verify
# Cyberdeck-BlackArch | MIT | Part of scripts/crypto/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "HASH-FILE" "File hashing — MD5/SHA1/SHA256/SHA512/BLAKE2 + verify"; cat <<USAGE
  USAGE: hash-file.sh <file...> [--verify <expected-hash>]
  Prints all major digests; checks VirusTotal link hint for the SHA256.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "HASH-FILE" "File hashing — MD5/SHA1/SHA256/SHA512/BLAKE2 + verify"; :; log_msg "START args: $*"

  [[ -n "${1:-}" ]] || die "Usage: hash-file <file...> [--verify HASH]"
  local expected=""; [[ "$*" == *"--verify"* ]] && expected="$(echo "$@"|grep -oE '[a-fA-F0-9]{32,128}'|tail -1)"
  for f in "$@"; do [[ -f "$f" && "$f" != "--verify" && "$f" != "$expected" ]] || continue
    section "$f"; kv "Size" "$(du -h "$f"|cut -f1) ($(stat -c%s "$f") bytes)"
    for a in md5sum sha1sum sha256sum sha512sum b2sum; do have $a && kv "${a%sum}" "$($a "$f"|cut -d' ' -f1)"; done
    local s256; s256="$(sha256sum "$f"|cut -d' ' -f1)"; info "VT lookup: https://www.virustotal.com/gui/file/$s256"
    [[ -n "$expected" ]] && { [[ "$s256" == "$expected" || "$(md5sum "$f"|cut -d' ' -f1)" == "$expected" ]] && ok "MATCHES expected hash" || err "DOES NOT match expected hash!"; }
    log_msg "hash $f sha256=$s256"; done
  log_msg "DONE"; }
main "$@"
