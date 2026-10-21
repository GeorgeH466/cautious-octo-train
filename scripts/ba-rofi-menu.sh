#!/usr/bin/env bash
# ==============================================================================
# BlackArch Cyberdeck - Rofi / FZF Quick Command Launcher
# Reads the shared ~/.config/blackarch-cyberdeck/commands.json database
# ==============================================================================
set -euo pipefail

CONFIG_DIR="${HOME}/.config/blackarch-cyberdeck"
COMMANDS_FILE="${CONFIG_DIR}/commands.json"
STATE_FILE="${CONFIG_DIR}/config.json"
ROFI_THEME="${HOME}/.config/rofi/blackarch-cyberdeck.rasi"

if [[ ! -f "${COMMANDS_FILE}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    if [[ -f "${SCRIPT_DIR}/configs/commands.default.json" ]]; then
        mkdir -p "${CONFIG_DIR}"
        cp "${SCRIPT_DIR}/configs/commands.default.json" "${COMMANDS_FILE}"
    fi
fi

TARGET="127.0.0.1"
LHOST="$(ip -4 -br addr show scope global 2>/dev/null | awk '{print $3}' | cut -d/ -f1 | head -n1 || echo '127.0.0.1')"
LPORT="4444"
INTERFACE="$(ip route show default 2>/dev/null | awk '{print $5; exit}' || echo 'eth0')"
WORDLIST="/usr/share/wordlists/rockyou.txt"

if [[ -f "${STATE_FILE}" ]] && command -v jq >/dev/null 2>&1; then
    TARGET="$(jq -r '.target // "127.0.0.1"' "${STATE_FILE}")"
    LHOST="$(jq -r ".lhost // \"${LHOST}\"" "${STATE_FILE}")"
    LPORT="$(jq -r '.lport // "4444"' "${STATE_FILE}")"
    INTERFACE="$(jq -r ".interface // \"${INTERFACE}\"" "${STATE_FILE}")"
    WORDLIST="$(jq -r ".wordlist // \"${WORDLIST}\"" "${STATE_FILE}")"
fi

MENU_LINES="$(jq -r '.[] | "[\(.category)] \(.name)  ::  \(.cmd)"' "${COMMANDS_FILE}")"

if command -v rofi >/dev/null 2>&1 && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
    if [[ -f "${ROFI_THEME}" ]]; then
        SELECTED="$(printf '%s\n' "${MENU_LINES}" | rofi -dmenu -i -p "BLACKARCH //" -theme "${ROFI_THEME}" -mesg "Target: ${TARGET} | LHOST: ${LHOST}:${LPORT} | Iface: ${INTERFACE}")"
    else
        SELECTED="$(printf '%s\n' "${MENU_LINES}" | rofi -dmenu -i -p "BLACKARCH //")"
    fi
elif command -v fzf >/dev/null 2>&1; then
    SELECTED="$(printf '%s\n' "${MENU_LINES}" | fzf --prompt="BLACKARCH // " --header="Target: ${TARGET} | LHOST: ${LHOST}:${LPORT}")"
else
    echo "Neither rofi nor fzf found. Launching full blackarch-deck TUI..."
    exec blackarch-deck
fi

[[ -z "${SELECTED:-}" ]] && exit 0

RAW_CMD="${SELECTED#*  ::  }"
RENDERED_CMD="${RAW_CMD//\{target\}/${TARGET}}"
RENDERED_CMD="${RENDERED_CMD//\{lhost\}/${LHOST}}"
RENDERED_CMD="${RENDERED_CMD//\{lport\}/${LPORT}}"
RENDERED_CMD="${RENDERED_CMD//\{interface\}/${INTERFACE}}"
RENDERED_CMD="${RENDERED_CMD//\{wordlist\}/${WORDLIST}}"

for TERM_BIN in kitty alacritty xfce4-terminal konsole gnome-terminal xterm; do
    if command -v "${TERM_BIN}" >/dev/null 2>&1 && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
        exec "${TERM_BIN}" -e bash -c "echo -e '\033[1;31m[BLACKARCH CYBERDECK]\033[0m Executing: \033[1;36m${RENDERED_CMD}\033[0m\n'; ${RENDERED_CMD}; echo -e '\n\033[1;32m[Press Enter to close]\033[0m'; read -r"
    fi
done

echo -e "\033[1;31m[BLACKARCH CYBERDECK]\033[0m Executing: \033[1;36m${RENDERED_CMD}\033[0m"
bash -c "${RENDERED_CMD}"
