#!/usr/bin/env bash
# ==============================================================================
# ⚔  BLACKARCH // CYBERDECK POST-INSTALL & UI SETUP SCRIPT (Dual-Boot Edition)
# ==============================================================================
# Sets up:
#   1. Pacman tuning & BlackArch repository verification (strap.sh if needed)
#   2. Dual-Boot PC fixes (RTC local-time sync for Windows, os-prober GRUB,
#      ntfs-3g / exfat support, CPU microcode, lm_sensors hardware temps)
#   3. Desktop HUD & Terminal Rice (Conky desktop widget, Rofi command launcher,
#      Fastfetch BlackArch banner, Nerd Fonts, Btop++)
#   4. blackarch-deck Command Center UI (Terminal Curses TUI + Graphical App UI)
#      with live hardware telemetry, weather, clock, OPSEC radar, and 45+
#      customizable menu-driven commands.
#
# Usage:
#   ./install.sh              # Interactive post-install setup
#   ./install.sh --all        # Full automated BlackArch dual-boot post-install
#   ./install.sh --ui-only    # Install only blackarch-deck & user configs (no root required)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config/blackarch-cyberdeck"
LOCAL_BIN="${HOME}/.local/bin"

RED='\033[1;31m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

banner() {
    echo -e "${RED}"
    cat << 'EOF'
  ____  _            _     _             _        ____      _               _           _    
 | __ )| | __ _  ___| | __/ \   _ __ ___| |__    / ___|   _| |__   ___ _ __| | ___  ___| | __
 |  _ \| |/ _` |/ __| |/ / _ \ | '__/ __| '_ \  | |  | | | | '_ \ / _ \ '__| |/ _ \/ __| |/ /
 | |_) | | (_| | (__|   < ___ \| | | (__| | | | | |__| |_| | |_) |  __/ |  | |  __/ (__|   < 
 |____/|_|\__,_|\___|_|\_\_/ \_\_|  \___|_| |_|  \____\__, |_.__/ \___|_|  |_|\___|\___|_|\_\
                                                      |___/                                  
EOF
    echo -e "${CYAN}  >> Post-Install Cyberdeck UI, Hardware/Weather HUD & Command Center (Dual-Boot PC Edition)${NC}"
    echo -e "${RED}==============================================================================================${NC}"
}

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }

MODE="interactive"
LOCATION_ARG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)      MODE="all"; shift ;;
        --ui-only)  MODE="ui-only"; shift ;;
        --location) LOCATION_ARG="${2:-}"; shift 2 ;;
        -h|--help)
            banner
            echo "Usage: ./install.sh [--all | --ui-only] [--location 'City, Country']"
            exit 0
            ;;
        *) shift ;;
    esac
done

setup_pacman_and_blackarch_repo() {
    if ! command -v pacman >/dev/null 2>&1; then
        warn "pacman not detected (non-Arch environment). Skipping pacman tuning."
        return 0
    fi

    info "Tuning /etc/pacman.conf (Color, ILoveCandy, ParallelDownloads)..."
    sudo sed -i 's/^#Color/Color/' /etc/pacman.conf || true
    sudo sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf || true
    sudo sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 8/' /etc/pacman.conf || true
    if ! grep -q "ILoveCandy" /etc/pacman.conf; then
        sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf || true
    fi

    if ! grep -q "\[blackarch\]" /etc/pacman.conf; then
        warn "BlackArch repository not found in /etc/pacman.conf. Running official strap.sh..."
        TMP_STRAP="$(mktemp -d)"
        curl -fsSL https://blackarch.org/strap.sh -o "${TMP_STRAP}/strap.sh"
        chmod +x "${TMP_STRAP}/strap.sh"
        sudo "${TMP_STRAP}/strap.sh"
        rm -rf "${TMP_STRAP}"
        ok "BlackArch repository bootstrapped!"
    else
        ok "BlackArch repository is already active in /etc/pacman.conf."
    fi
}

setup_dualboot_and_hardware() {
    if ! command -v pacman >/dev/null 2>&1; then
        warn "Skipping Arch package installation on non-Arch host."
        return 0
    fi

    info "Installing Dual-Boot & Hardware Telemetry packages..."
    PKGS=(
        python
        iproute2
        pciutils
        usbutils
        lm_sensors
        acpi
        os-prober
        ntfs-3g
        exfatprogs
        dosfstools
        curl
        jq
        fzf
        btop
        fastfetch
        conky
        rofi
        tmux
    )

    # Detect CPU vendor for microcode on regular PC
    if grep -q "AuthenticAMD" /proc/cpuinfo 2>/dev/null; then
        PKGS+=(amd-ucode)
    elif grep -q "GenuineIntel" /proc/cpuinfo 2>/dev/null; then
        PKGS+=(intel-ucode)
    fi

    sudo pacman -Sy --needed --noconfirm "${PKGS[@]}" || warn "Some optional packages could not be installed."

    info "Applying Dual-Boot Windows/Linux RTC Hardware Clock fix (Local RTC)..."
    if command -v timedatectl >/dev/null 2>&1; then
        sudo timedatectl set-local-rtc 1 --adjust-system-clock 2>/dev/null || true
        ok "Hardware clock set to Local RTC (prevents clock skew when dual-booting Windows)."
    fi

    if [[ -f /etc/default/grub ]] && command -v grub-mkconfig >/dev/null 2>&1; then
        info "Enabling os-prober in /etc/default/grub for Dual-Boot OS detection..."
        if grep -q "GRUB_DISABLE_OS_PROBER" /etc/default/grub; then
            sudo sed -i 's/^#*GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
        else
            echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a /etc/default/grub >/dev/null
        fi
        sudo grub-mkconfig -o /boot/grub/grub.cfg || warn "grub-mkconfig skipped."
        ok "GRUB updated with dual-boot OS prober."
    fi

    if command -v sensors-detect >/dev/null 2>&1; then
        sudo sensors-detect --auto >/dev/null 2>&1 || true
    fi
}

install_cyberdeck_ui_and_configs() {
    info "Installing BlackArch Cyberdeck UI (blackarch-deck) & configuration files..."
    mkdir -p "${CONFIG_DIR}" "${LOCAL_BIN}"
    mkdir -p "${HOME}/.config/conky" "${HOME}/.config/rofi" "${HOME}/.config/fastfetch"
    mkdir -p "${HOME}/.config/autostart" "${HOME}/.local/share/applications"

    chmod +x "${SCRIPT_DIR}/blackarch-deck" "${SCRIPT_DIR}/scripts/ba-rofi-menu.sh"

    # Copy command library if not already customized
    if [[ ! -f "${CONFIG_DIR}/commands.json" ]]; then
        cp "${SCRIPT_DIR}/configs/commands.default.json" "${CONFIG_DIR}/commands.json"
        ok "Installed 45+ pre-configured commands to ${CONFIG_DIR}/commands.json"
    else
        ok "Preserved existing custom commands in ${CONFIG_DIR}/commands.json"
    fi

    # Install binaries to ~/.local/bin (and /usr/local/bin if writable or sudo available)
    cp "${SCRIPT_DIR}/blackarch-deck" "${LOCAL_BIN}/blackarch-deck"
    cp "${SCRIPT_DIR}/scripts/ba-rofi-menu.sh" "${LOCAL_BIN}/ba-rofi"
    chmod +x "${LOCAL_BIN}/blackarch-deck" "${LOCAL_BIN}/ba-rofi"

    if [[ -w /usr/local/bin ]]; then
        cp "${SCRIPT_DIR}/blackarch-deck" /usr/local/bin/blackarch-deck
        cp "${SCRIPT_DIR}/scripts/ba-rofi-menu.sh" /usr/local/bin/ba-rofi
    elif command -v sudo >/dev/null 2>&1 && [[ "${MODE}" != "ui-only" ]]; then
        sudo cp "${SCRIPT_DIR}/blackarch-deck" /usr/local/bin/blackarch-deck 2>/dev/null || true
        sudo cp "${SCRIPT_DIR}/scripts/ba-rofi-menu.sh" /usr/local/bin/ba-rofi 2>/dev/null || true
    fi

    # Install Conky, Rofi & Fastfetch configs
    cp "${SCRIPT_DIR}/configs/conky-blackarch.conf" "${HOME}/.config/conky/blackarch-hud.conf"
    cp "${SCRIPT_DIR}/configs/rofi-blackarch.rasi" "${HOME}/.config/rofi/blackarch-cyberdeck.rasi"
    cp "${SCRIPT_DIR}/configs/fastfetch.jsonc" "${HOME}/.config/fastfetch/config.jsonc"

    # Create Conky Desktop Autostart Entry
    cat > "${HOME}/.config/autostart/blackarch-conky.desktop" << EOF
[Desktop Entry]
Type=Application
Name=BlackArch Cyberdeck Conky HUD
Comment=Desktop Hardware, Weather & OPSEC Telemetry Overlay
Exec=conky -c ${HOME}/.config/conky/blackarch-hud.conf -d
Terminal=false
Categories=System;Monitor;Security;
EOF

    # Create Application Menu Launchers
    cat > "${HOME}/.local/share/applications/blackarch-cyberdeck-tui.desktop" << EOF
[Desktop Entry]
Type=Application
Name=BlackArch Cyberdeck (Terminal UI)
Comment=Full-screen Terminal Hardware, Weather & Command Center UI
Exec=${LOCAL_BIN}/blackarch-deck
Terminal=true
Categories=System;Security;
EOF

    cat > "${HOME}/.local/share/applications/blackarch-cyberdeck-gui.desktop" << EOF
[Desktop Entry]
Type=Application
Name=BlackArch Cyberdeck (Graphical App)
Comment=Graphical Cyberdeck Dashboard & Interactive Command Center
Exec=${LOCAL_BIN}/blackarch-deck --gui
Terminal=false
Categories=System;Security;
EOF

    # Add convenient aliases to ~/.bashrc and ~/.zshrc
    ALIAS_BLOCK=$(cat << 'EOF'

# >>> BlackArch Cyberdeck UI Aliases >>>
export PATH="$HOME/.local/bin:$PATH"
alias deck='blackarch-deck'
alias ba-ui='blackarch-deck'
alias deck-gui='blackarch-deck --gui'
alias deck-web='blackarch-deck --web'
alias deck-status='blackarch-deck --status'
# <<< BlackArch Cyberdeck UI Aliases <<<
EOF
)
    for rc_file in "${HOME}/.bashrc" "${HOME}/.zshrc"; do
        if [[ -f "${rc_file}" ]] && ! grep -q "BlackArch Cyberdeck UI Aliases" "${rc_file}"; then
            printf "%s\n" "${ALIAS_BLOCK}" >> "${rc_file}"
            ok "Added Cyberdeck shortcuts ('deck', 'deck-gui', 'deck-status', 'ba-rofi') to ${rc_file}"
        fi
    done

    if [[ -n "${LOCATION_ARG}" ]]; then
        "${LOCAL_BIN}/blackarch-deck" --status --location "${LOCATION_ARG}" >/dev/null 2>&1 || true
    fi

    ok "BlackArch Cyberdeck UI installed!"
}

banner

if [[ "${MODE}" == "ui-only" ]]; then
    install_cyberdeck_ui_and_configs
elif [[ "${MODE}" == "all" ]]; then
    setup_pacman_and_blackarch_repo
    setup_dualboot_and_hardware
    install_cyberdeck_ui_and_configs
else
    echo -e "${CYAN}Select setup mode for your BlackArch Dual-Boot PC:${NC}"
    echo "  1) Full Post-Install (Pacman + BlackArch Repo + Dual-Boot RTC/GRUB/NTFS + Desktop HUD + Cyberdeck UI)"
    echo "  2) Cyberdeck UI & Desktop Configs Only (No root/pacman changes)"
    read -r -p "Enter choice [1/2, default=1]: " CHOICE
    if [[ "${CHOICE:-1}" == "2" ]]; then
        install_cyberdeck_ui_and_configs
    else
        setup_pacman_and_blackarch_repo
        setup_dualboot_and_hardware
        install_cyberdeck_ui_and_configs
    fi
fi

echo ""
"${LOCAL_BIN}/blackarch-deck" --status
echo ""
echo -e "${GREEN}Setup Complete! Launch your UI anytime with:${NC}"
echo -e "  • ${CYAN}blackarch-deck${NC}          (or ${CYAN}deck${NC})      -> Full-Screen Terminal Cyberdeck TUI"
echo -e "  • ${CYAN}blackarch-deck --gui${NC}    (or ${CYAN}deck-gui${NC})  -> Graphical Desktop Cyberdeck App"
echo -e "  • ${CYAN}blackarch-deck --web${NC}    (or ${CYAN}deck-web${NC})  -> Web Dashboard on http://0.0.0.0:8080"
echo -e "  • ${CYAN}ba-rofi${NC}                               -> Quick Popup Rofi/FZF Command Launcher"
