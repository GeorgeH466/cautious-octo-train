#!/usr/bin/env bash
# integrity-check.sh — File integrity checker — baseline & verify critical paths
# Cyberdeck-BlackArch | MIT | Part of scripts/defense/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "INTEGRITY-CHECK" "File integrity checker — baseline & verify critical paths"; cat <<USAGE
  USAGE: integrity-check.sh <baseline|verify|diff>
  Hashes /etc, /usr/bin, /bin, sshd config etc. with SHA-256 into ~/.cyberdeck/integrity.db
  Uses AIDE instead when it is installed & initialised.
USAGE
  printf '\n  %sLogs: ~/.cyberdeck/logs/   Reports: ~/.cyberdeck/reports/%s\n' "$C_MUTED" "$C_RESET"; }
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(sha256sum:coreutils); check_deps "${DEPS[@]}" || exit 1
main() { cyber_banner "INTEGRITY-CHECK" "File integrity checker — baseline & verify critical paths"; :; log_msg "START args: $*"

  local db="$CYBERDECK_HOME/integrity.db" paths=(/etc/passwd /etc/shadow /etc/ssh /etc/sudoers /etc/crontab /usr/bin /bin "$HOME/.ssh")
  case "${1:-verify}" in
    baseline) info "Creating baseline (can take a minute)…"; sudo find "${paths[@]}" -type f 2>/dev/null | sort | sudo xargs -r sha256sum 2>/dev/null | tee "$db" >/dev/null; ok "Baseline: $(wc -l <"$db") files → $db" ;;
    verify) [[ -f "$db" ]] || die "No baseline — run: integrity-check baseline"; if have aide && [[ -f /var/lib/aide/aide.db ]]; then sudo aide --check 2>&1 | tail -30 | sed 's/^/  /'; else sudo sha256sum -c "$db" 2>/dev/null | grep -v ': OK$' | sed 's/^/  [▲] /' | tee -a "$LOG_FILE"; ok "Verify done (only changes shown above; nothing = clean)."; fi ;;
    diff) [[ -f "$db" ]] || die "No baseline"; sudo find "${paths[@]}" -type f 2>/dev/null | sort > /tmp/cd-now.txt; cut -d' ' -f3- "$db" | sort > /tmp/cd-base.txt; diff /tmp/cd-base.txt /tmp/cd-now.txt | head -40 | sed 's/^</  removed:/;s/^>/  added:/' ;;
    *) die "Usage: integrity-check baseline|verify|diff";;
  esac; log_msg "integrity ${1:-verify}"
  log_msg "DONE"; }
main "$@"
