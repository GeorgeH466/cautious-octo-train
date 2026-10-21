#!/usr/bin/env bash
# steganography.sh — Hide / extract data in images & audio (steghide + binwalk)
# Cyberdeck-BlackArch | MIT | Part of scripts/crypto/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "STEGANOGRAPHY" "Hide / extract data in images & audio (steghide + binwalk)"; cat <<USAGE
  USAGE: steganography.sh <hide <cover.jpg> <secret-file> | extract <file.jpg> | info <file> | crack <file> <wordlist>>
  Works with JPEG/WAV/BMP via steghide; info also runs strings/exif/binwalk.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "STEGANOGRAPHY" "Hide / extract data in images & audio (steghide + binwalk)"; :; log_msg "START args: $*"

  local cmd="${1:-}"
  case "$cmd" in
    hide) have steghide || die "steghide required (sudo pacman -S steghide)"; [[ -f "${2:-}" && -f "${3:-}" ]] || die "Usage: steganography hide cover.jpg secret.txt"; read -rsp "  Steghide passphrase: " pw </dev/tty; echo; steghide embed -cf "$2" -ef "$3" -p "$pw" -f; ok "Embedded $3 into $2 (cover modified in place — keep a backup!)" ;;
    extract) have steghide || die "steghide required"; [[ -f "${2:-}" ]] || die "file required"; read -rsp "  Passphrase (blank=none): " pw </dev/tty; echo; steghide extract -sf "$2" -p "$pw" -xf "$CYBERDECK_HOME/captures/extracted-$(timestamp).bin" && ok "Extracted to ~/.cyberdeck/captures/" ;;
    info) [[ -f "${2:-}" ]] || die "file required"; file "$2" | sed 's/^/  /'; have steghide && steghide info "$2" -p "" 2>&1 | head -5 | sed 's/^/  /'; have exiftool && exiftool -s -s -s -Model -Software -Comment "$2" 2>/dev/null | sed 's/^/  exif: /'; have binwalk && binwalk "$2" | head -15 | sed 's/^/  /'; info "Appended-data check:"; strings -n 8 "$2" | tail -8 | sed 's/^/    /' ;;
    crack) have steghide || die "steghide required"; [[ -f "${2:-}" && -f "${3:-}" ]] || die "Usage: crack file wordlist"; while read -r p; do steghide extract -sf "$2" -p "$p" -xf /tmp/steg-out.bin 2>/dev/null && { ok "Passphrase found: '$p' → /tmp/steg-out.bin"; exit 0; }; done <"$3"; err "Passphrase not in wordlist."; exit 1 ;;
    *) die "Usage: steganography hide|extract|info|crack ..." ;;
  esac; log_msg "steg $*"
  log_msg "DONE"; }
main "$@"
