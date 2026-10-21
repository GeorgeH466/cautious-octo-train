#!/usr/bin/env bash
# session-manager.sh — Save / restore named tmux 'mission' sessions
# Cyberdeck-BlackArch | MIT | Part of scripts/cyberdeck/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "SESSION-MANAGER" "Save / restore named tmux 'mission' sessions"; cat <<USAGE
  USAGE: session-manager.sh <save <name>|restore <name>|list|kill <name>|attach [name]>
  save snapshots window/pane layout & cwd of the current tmux session to ~/.cyberdeck/sessions/.
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
DEPS=(tmux:tmux); check_deps "${DEPS[@]}" || exit 1
main() { cyber_banner "SESSION-MANAGER" "Save / restore named tmux 'mission' sessions"; log_msg "START args: $*"

  local sdir="$CYBERDECK_HOME/sessions"; mkdir -p "$sdir"
  case "${1:-list}" in
    list) section "TMUX SESSIONS (live)"; tmux ls 2>/dev/null | sed 's/^/  /' || offline "none running"; section "SAVED MISSIONS"; ls "$sdir"/*.session 2>/dev/null | xargs -rn1 basename | sed 's/.session//;s/^/  ▸ /' ;;
    save) local name="${2:?name required}"; [[ -n "${TMUX:-}" ]] || die "Run save from INSIDE the tmux session to snapshot."
      tmux list-windows -F '#{window_index} #{window_name} #{window_layout}' >"$sdir/$name.session"
      tmux list-panes -a -F '#{window_index}.#{pane_index} #{pane_current_path} #{pane_current_command}' >>"$sdir/$name.session"
      ok "Mission '$name' saved → $sdir/$name.session"; log_msg "session save $name" ;;
    restore) local name="${2:?name required}"; [[ -f "$sdir/$name.session" ]] || die "No saved mission '$name'"
      tmux has-session -t "$name" 2>/dev/null && { info "Session exists — attaching"; exec tmux attach -t "$name"; }
      tmux new-session -d -s "$name"
      # Recreate windows/panes from snapshot (layout applied best-effort)
      grep -E '^[0-9]+ ' "$sdir/$name.session" | tail -n +2 | while read -r idx wname layout; do tmux new-window -t "$name:$idx" -n "$wname" 2>/dev/null; [[ -n "$layout" ]] && tmux select-layout -t "$name:$idx" "$layout" 2>/dev/null; done
      ok "Mission '$name' restored"; [[ -z "${TMUX:-}" ]] && exec tmux attach -t "$name" || tmux switch-client -t "$name" ;;
    kill) tmux kill-session -t "${2:?name}" && ok "Killed $2";;
    attach) exec tmux attach ${2:+-t "$2"} ;;
    *) die "Usage: session-manager save|restore|list|kill|attach";;
  esac
  log_msg "DONE"; }
main "$@"
