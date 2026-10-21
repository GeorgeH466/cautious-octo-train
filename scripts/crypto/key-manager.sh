#!/usr/bin/env bash
# key-manager.sh — GPG & age key management
# Cyberdeck-BlackArch | MIT | Part of scripts/crypto/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "KEY-MANAGER" "GPG & age key management"; cat <<USAGE
  USAGE: key-manager.sh <list|gen-gpg|gen-age|export <id>|import <file>|sign <file>|verify <file.sig>>
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(gpg:gnupg); check_deps "${DEPS[@]}" || exit 1
main() { cyber_banner "KEY-MANAGER" "GPG & age key management"; :; log_msg "START args: $*"

  case "${1:-list}" in
    list) section "GPG SECRET KEYS"; gpg --list-secret-keys --keyid-format long 2>/dev/null | sed 's/^/  /'; section "AGE KEYS"; ls -l "$HOME/.config/age" 2>/dev/null | sed 's/^/  /'; grep -h 'public key:' "$HOME/.config/age/"*.txt 2>/dev/null | sed 's/^/  /'; section "SSH KEYS"; ls -l "$HOME/.ssh/"*.pub 2>/dev/null | sed 's/^/  /'; ssh-add -l 2>/dev/null | sed 's/^/  agent: /' ;;
    gen-gpg) info "Launching GPG full key generation wizard…"; gpg --full-generate-key ;;
    gen-age) have age-keygen || die "age required (sudo pacman -S age)"; mkdir -p "$HOME/.config/age"; local k="$HOME/.config/age/key-$(date +%Y%m%d).txt"; age-keygen -o "$k" 2>&1 | sed 's/^/  /'; chmod 600 "$k"; ok "age key: $k" ;;
    export) [[ -n "${2:-}" ]] || die "key id required"; gpg --armor --export "$2" >"$CYBERDECK_HOME/reports/gpg-$2.pub.asc"; ok "Exported → ~/.cyberdeck/reports/gpg-$2.pub.asc" ;;
    import) gpg --import "${2:?file}" ;;
    sign) gpg --detach-sign --armor -o "${2:?file}.sig" "$2" && ok "Signed → $2.sig" ;;
    verify) gpg --verify "${2:?sigfile}" "${2%.sig}" ;;
    *) die "Usage: key-manager list|gen-gpg|gen-age|export|import|sign|verify" ;;
  esac; log_msg "keys $*"
  log_msg "DONE"; }
main "$@"
