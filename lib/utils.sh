#!/usr/bin/env bash
# lib/utils.sh — Logging, dependency checks, privilege & network helpers
[[ -n "${_CYBERDECK_UTILS_LOADED:-}" ]] && return 0
_CYBERDECK_UTILS_LOADED=1
_UTIL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
for _f in "$_UTIL_DIR/colors.sh" "$_UTIL_DIR/ui.sh" "$HOME/.cyberdeck/lib/colors.sh" "$HOME/.cyberdeck/lib/ui.sh"; do [[ -f "$_f" ]] && source "$_f"; done

CYBERDECK_HOME="${CYBERDECK_HOME:-$HOME/.cyberdeck}"
CYBERDECK_LOG_DIR="$CYBERDECK_HOME/logs"
mkdir -p "$CYBERDECK_LOG_DIR" "$CYBERDECK_HOME"/{sessions,captures,wordlists,notes,targets,reports} 2>/dev/null || true
SCRIPT_NAME="$(basename "${0:-cyberdeck}")"
LOG_FILE="$CYBERDECK_LOG_DIR/${SCRIPT_NAME%.sh}-$(date +%Y%m%d).log"
log_msg() { printf '[%s] [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$SCRIPT_NAME" "$*" >>"$LOG_FILE" 2>/dev/null || true; }
die() { err "$*"; log_msg "FATAL: $*"; exit 1; }
# strip ANSI for logs / piping
strip_ansi() { sed -E 's/\x1B\[[0-9;]*m//g'; }
require_root() { [[ $EUID -eq 0 ]] && return 0; warn "This action needs root — re-running with sudo…"; exec sudo -E bash "$0" "$@"; }
have() { command -v "$1" >/dev/null 2>&1; }
# check_deps cmd[:pkg] ...  — offers pacman install for missing tools
check_deps() {
  local missing=() spec cmd pkg
  for spec in "$@"; do cmd="${spec%%:*}"; pkg="${spec#*:}"; [[ "$pkg" == "$cmd" ]] && pkg="$cmd"; have "$cmd" || missing+=("$pkg:$cmd"); done
  [[ ${#missing[@]} -eq 0 ]] && return 0
  warn "Missing dependencies:"
  for spec in "${missing[@]}"; do printf '    %s %s (package: %s)\n' "$SYM_OFFLINE" "${spec#*:}" "${spec%%:*}"; done
  log_msg "missing deps: ${missing[*]}"
  if have pacman && confirm "Install missing packages with pacman?"; then
    local pkgs=(); for spec in "${missing[@]}"; do pkgs+=("${spec%%:*}"); done
    sudo pacman -S --needed --noconfirm "${pkgs[@]}" || warn "pacman failed — try your AUR helper (yay) for: ${pkgs[*]}"
    local still=0; for spec in "${missing[@]}"; do have "${spec#*:}" || still=1; done; [[ $still -eq 0 ]] && { ok "Dependencies satisfied."; return 0; }
  fi
  err "Cannot continue without: ${missing[*]}"; return 1
}
default_iface() { ip route show default 2>/dev/null | awk 'NR==1{print $5}'; }
local_ip() { ip -4 -o addr show scope global 2>/dev/null | awk 'NR==1{split($4,a,"/"); print a[1]}'; }
public_ip() { curl -fsS --max-time 5 https://icanhazip.com 2>/dev/null || curl -fsS --max-time 5 https://ifconfig.me 2>/dev/null || echo "unknown"; }
gateway_ip() { ip route show default 2>/dev/null | awk 'NR==1{print $3}'; }
local_subnet() { ip -4 -o addr show scope global 2>/dev/null | awk 'NR==1{print $4}'; }
timestamp() { date '+%Y%m%d-%H%M%S'; }
outdir() { local d="$CYBERDECK_HOME/reports/$(timestamp)-$1"; mkdir -p "$d"; echo "$d"; }
is_ip() { [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?$ ]]; }
pause_enter() { printf '\n  %sPress Enter to continue…%s' "$C_MUTED" "$C_RESET"; read -r _ </dev/tty 2>/dev/null || true; }
run_logged() { log_msg "RUN: $*"; printf '  %s$ %s%s\n' "$C_MUTED" "$*" "$C_RESET"; "$@" 2>&1 | tee -a "$LOG_FILE"; return "${PIPESTATUS[0]}"; }
# Find cyberdeck lib dir from any script location
cyberdeck_lib() { local d; d="$(cd "$(dirname "${BASH_SOURCE[1]:-$0}")" 2>/dev/null && pwd)"; for c in "$d/../../lib" "$d/../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib" "/usr/local/share/cyberdeck/lib"; do [[ -f "$c/colors.sh" ]] && { echo "$c"; return; }; done; echo "$HOME/.cyberdeck/lib"; }
