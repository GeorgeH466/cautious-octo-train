#!/usr/bin/env bash
# password-gen.sh — Secure password & passphrase generator (CSPRNG)
# Cyberdeck-BlackArch | MIT | Part of scripts/crypto/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "PASSWORD-GEN" "Secure password & passphrase generator (CSPRNG)"; cat <<USAGE
  USAGE: password-gen.sh [length] [count] [--words N] [--pin]
  Default: 5 passwords of 20 chars. --words 5 → diceware-style passphrases. Copies first to clipboard if xclip present.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(openssl:openssl); check_deps "${DEPS[@]}" || exit 1
main() { cyber_banner "PASSWORD-GEN" "Secure password & passphrase generator (CSPRNG)"; :; log_msg "START args: $*"

  local len=20 count=5 words=0 pin=0
  for a in "$@"; do case "$a" in --words) words=5;; --pin) pin=1;; ''|*[!0-9]*) ;; *) [[ $len -eq 20 ]] && len=$a || count=$a;; esac; done
  [[ "$*" =~ --words\ ([0-9]+) ]] && words="${BASH_REMATCH[1]}"
  section "GENERATED CREDENTIALS"
  local first=""
  for i in $(seq 1 "$count"); do local pw=""
    if [[ $pin -eq 1 ]]; then pw="$(openssl rand -base64 12 | tr -dc '0-9' | head -c "${len:-6}")"
    elif [[ $words -gt 0 ]]; then local wl=/usr/share/dict/words; [[ -f $wl ]] || wl="$CYBERDECK_HOME/wordlists/words.txt"; [[ -f $wl ]] || { curl -fsSL -o "$wl" "https://raw.githubusercontent.com/jeremy-rifkin/Wordlist/master/master.txt" 2>/dev/null || die "No wordlist for passphrases (offline?)"; }; pw="$(shuf -n "$words" "$wl" | tr -d "'" | paste -sd-)-$((RANDOM%90+10))"
    else pw="$(LC_ALL=C tr -dc 'A-Za-z0-9!@#%^*_+=-' </dev/urandom | head -c "$len")"; fi
    [[ -z "$first" ]] && first="$pw"; printf '  %s▸%s %s\n' "$C_PRIMARY" "$C_RESET" "$pw"; done
  have xclip && printf '%s' "$first" | xclip -selection clipboard 2>/dev/null && info "First password copied to clipboard."
  ok "Entropy source: /dev/urandom / openssl. Store in a password manager, never in plain text."; log_msg "password-gen count=$count words=$words pin=$pin"
  log_msg "DONE"; }
main "$@"
