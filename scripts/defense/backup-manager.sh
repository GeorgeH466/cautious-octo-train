#!/usr/bin/env bash
# backup-manager.sh — Encrypted backup manager (tar + GPG/age)
# Cyberdeck-BlackArch | MIT | Part of scripts/defense/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "BACKUP-MANAGER" "Encrypted backup manager (tar + GPG/age)"; cat <<USAGE
  USAGE: backup-manager.sh <backup [dirs...]|list|restore <archive>|verify <archive>>
  Default backup set: ~/.cyberdeck ~/.config ~/.ssh ~/Documents. Encrypts with age or gpg symmetric.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(tar:tar); check_deps "${DEPS[@]}" || exit 1
main() { cyber_banner "BACKUP-MANAGER" "Encrypted backup manager (tar + GPG/age)"; :; log_msg "START args: $*"

  local bdir="$CYBERDECK_HOME/backups"; mkdir -p "$bdir"
  case "${1:-list}" in
    backup) shift; local -a srcs=("$@"); [[ ${#srcs[@]} -eq 0 ]] && srcs=("$HOME/.cyberdeck" "$HOME/.config" "$HOME/.ssh" "$HOME/Documents")
      local arc="$bdir/backup-$(timestamp).tar.gz"; info "Archiving ${srcs[*]} → $arc"
      tar --exclude='*.pcap' --exclude='backups' -czf "$arc" "${srcs[@]}" 2>/dev/null
      if have age; then read -rsp "  Encryption passphrase: " pw </dev/tty; echo; age --passphrase -o "$arc.age" "$arc" <<<"$pw" && rm "$arc" && arc="$arc.age"
      elif have gpg; then gpg --batch --symmetric --cipher-algo AES256 -o "$arc.gpg" "$arc" && rm "$arc" && arc="$arc.gpg"; else warn "No age/gpg — archive left UNENCRYPTED"; fi
      sha256sum "$arc" >"$arc.sha256"; ok "Backup: $arc ($(du -h "$arc"|cut -f1))  checksum saved"; log_msg "backup $arc" ;;
    list) ls -lh "$bdir" | tail -n +2 | sed 's/^/  /' ;;
    verify) (cd "$bdir" && sha256sum -c "$(basename ${2:?archive}).sha256") | sed 's/^/  /' ;;
    restore) local a="${2:?archive required}"; local dest="$CYBERDECK_HOME/restore-$(timestamp)"; mkdir -p "$dest"
      case "$a" in *.age) age --decrypt -o /tmp/cd-restore.tar.gz "$a";; *.gpg) gpg --decrypt -o /tmp/cd-restore.tar.gz "$a";; *) cp "$a" /tmp/cd-restore.tar.gz;; esac
      tar -xzf /tmp/cd-restore.tar.gz -C "$dest"; rm -f /tmp/cd-restore.tar.gz; ok "Restored into $dest (nothing overwritten)";;
    *) die "Usage: backup-manager backup|list|restore|verify";;
  esac
  log_msg "DONE"; }
main "$@"
