#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════
#  CYBERDECK-BLACKARCH // MASTER INSTALLER
#  Transforms a BlackArch/Arch installation into a cyberdeck operations
#  environment.  Usage:
#    ./install.sh                interactive (choose full/minimal/custom)
#    ./install.sh --full         everything, non-interactive confirms
#    ./install.sh --minimal      configs + scripts + core packages only
#    ./install.sh --configs      only re-apply config files & scripts
#    ./install.sh --dry-run      print what would happen, change nothing
#    ./install.sh --help
# ════════════════════════════════════════════════════════════════════════
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DECK="$HOME/.cyberdeck"
BACKUP_DIR="$DECK/backups/config-backup-$(date +%Y%m%d-%H%M%S)"
MODE="ask"; DRY=0
for a in "$@"; do case "$a" in
  --full) MODE="full";; --minimal) MODE="minimal";; --configs) MODE="configs";;
  --dry-run) DRY=1;;
  --help|-h) grep -E '^#' "$0" | head -30 | sed 's/^# \{0,1\}//'; exit 0;;
esac; done

# Shared UI (fall back gracefully before lib is installed)
source "$REPO_DIR/lib/colors.sh" 2>/dev/null || true
source "$REPO_DIR/lib/ui.sh" 2>/dev/null || { ok(){ echo "[✔] $*"; }; err(){ echo "[✖] $*" >&2; }; warn(){ echo "[▲] $*"; }; info(){ echo "[◆] $*"; }; section(){ echo "┌─[ $1 ]"; }; cyber_banner(){ echo "◢ CYBERDECK — $1"; }; confirm(){ read -rp "$1 [y/N] " r; [[ "$r" =~ ^[Yy] ]]; }; }
mkdir -p "$DECK/logs"; LOG="$DECK/logs/install-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1
run() { if [[ $DRY -eq 1 ]]; then info "[dry-run] $*"; else "$@"; fi; }
have() { command -v "$1" >/dev/null 2>&1; }

cyber_banner "INSTALLER" "BLACKARCH → CYBERDECK TRANSFORMATION SEQUENCE"

# ── 1. Platform detection ─────────────────────────────────────────────────
section "PLATFORM DETECTION"
OS_ID="$(grep -oP '^ID=\K.*' /etc/os-release 2>/dev/null | tr -d '"')"
OS_LIKE="$(grep -oP '^ID_LIKE=\K.*' /etc/os-release 2>/dev/null | tr -d '"')"
IS_BLACKARCH=0; grep -qi blackarch /etc/pacman.conf /etc/os-release 2>/dev/null && IS_BLACKARCH=1
kv "Distro" "${OS_ID:-unknown} ${OS_LIKE:+($OS_LIKE)}"
kv "BlackArch repos" "$([[ $IS_BLACKARCH -eq 1 ]] && echo detected || echo 'not detected')"
kv "Architecture" "$(uname -m)"
if ! have pacman; then
  err "pacman not found. Cyberdeck-BlackArch targets Arch/BlackArch."
  warn "Continuing in CONFIGS-ONLY mode (packages skipped) so the deck still installs."
  MODE="configs"
fi
[[ "$(uname -m)" != "x86_64" ]] && warn "Non-x86_64 host — most BlackArch tools still work, some binaries may not."
[[ $EUID -eq 0 ]] && { err "Do not run as root — run as your normal user (sudo is invoked where needed)."; exit 1; }

# ── 2. Mode selection ─────────────────────────────────────────────────────
if [[ "$MODE" == "ask" ]]; then
  section "INSTALL PROFILE"
  printf '  1 ▸ FULL     — every package group, fonts, TUI, sounds (several GB, long)\n'
  printf '  2 ▸ MINIMAL  — core desktop + scripts/configs + essential tools\n'
  printf '  3 ▸ CUSTOM   — pick package groups one by one\n'
  printf '  4 ▸ CONFIGS  — dotfiles/scripts/themes only, no packages\n'
  printf '  Select [1-4] (default 2): '; read -r sel </dev/tty || sel=2
  case "$sel" in 1) MODE=full;; 3) MODE=custom;; 4) MODE=configs;; *) MODE=minimal;; esac
fi
info "Profile: $MODE   Log: $LOG"

WANT_CORE=1 WANT_NET=0 WANT_RECON=0 WANT_EXPLOIT=0 WANT_DEFENSE=0 WANT_CRYPTO=0 WANT_VISUAL=0 WANT_PIP=1 WANT_FONTS=1
case "$MODE" in
  full) WANT_NET=1 WANT_RECON=1 WANT_EXPLOIT=1 WANT_DEFENSE=1 WANT_CRYPTO=1 WANT_VISUAL=1;;
  minimal) WANT_NET=1 WANT_DEFENSE=1 WANT_CRYPTO=1;;
  custom)
    for g in NET RECON EXPLOIT DEFENSE CRYPTO VISUAL PIP FONTS; do
      confirm "Install package group: $g?" && eval "WANT_$g=1" || eval "WANT_$g=0"
    done;;
  configs) WANT_CORE=0 WANT_PIP=0 WANT_FONTS=0;;
esac

# ── Package groups (pacman names; BlackArch repo supplies the sec tools) ─
PKG_CORE=(i3-gaps polybar picom alacritty rofi dunst ranger tmux zsh neofetch conky feh scrot xclip xdotool i3lock-color xss-lock dialog fzf htop jq curl wget git vim xorg-xinit ImageMagick papirus-icon-theme ttf-jetbrains-mono-nerd ttf-firacode-nerd ttf-hack-nerd)
PKG_NET=(nmap wireshark-cli tcpdump aircrack-ng ettercap gnu-netcat socat iftop nethogs iw wireless_tools macchanger openvpn wireguard-tools tor proxychains-ng bind whois traceroute mtr masscan hping arp-scan iperf3)
PKG_RECON=(theharvester recon-ng sublist3r amass whatweb wafw00f nikto gobuster ffuf nuclei httpie)
PKG_EXPLOIT=(metasploit sqlmap john hashcat hydra medusa searchsploit exploitdb)
PKG_DEFENSE=(rkhunter chkrootkit aide fail2ban ufw clamav lynis)
PKG_CRYPTO=(gnupg age steghide binwalk foremost)
PKG_VISUAL=(cava cbonsai cool-retro-term cmatrix figlet)
AUR_PKGS=(pipes.sh capitaine-cursors)

pac_install() {
  local -a pkgs=("$@"); [[ ${#pkgs[@]} -eq 0 ]] && return 0
  [[ $DRY -eq 1 ]] && { info "[dry-run] pacman -S ${pkgs[*]}"; return 0; }
  info "Installing (${#pkgs[@]}): ${pkgs[*]:0:120}…"
  if ! sudo pacman -S --needed --noconfirm "${pkgs[@]}"; then
    warn "Bulk install hit a missing package — retrying individually so one bad name can't block the rest…"
    local p; for p in "${pkgs[@]}"; do sudo pacman -S --needed --noconfirm "$p" || warn "Skipped unavailable package: $p (check BlackArch/AUR)"; done
  fi
}
ensure_yay() {
  have yay && return 0; have paru && { alias yay=paru 2>/dev/null; return 0; }
  [[ $DRY -eq 1 ]] && { info "[dry-run] bootstrap yay"; return 1; }
  info "Bootstrapping yay (AUR helper)…"
  sudo pacman -S --needed --noconfirm git base-devel || return 1
  local tmp; tmp="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin" && (cd "$tmp/yay-bin" && makepkg -si --noconfirm) && rm -rf "$tmp" && have yay
}

if [[ "$MODE" != "configs" ]] && have pacman; then
  section "PACKAGE INSTALLATION"
  [[ $IS_BLACKARCH -eq 0 ]] && info "Tip: add BlackArch repos for the full toolset → https://blackarch.org/downloads.html (#strap)"
  run sudo pacman -Sy
  [[ $WANT_CORE -eq 1 ]] && pac_install "${PKG_CORE[@]}"
  [[ $WANT_NET -eq 1 ]] && pac_install "${PKG_NET[@]}"
  [[ $WANT_RECON -eq 1 ]] && pac_install "${PKG_RECON[@]}"
  [[ $WANT_EXPLOIT -eq 1 ]] && pac_install "${PKG_EXPLOIT[@]}"
  [[ $WANT_DEFENSE -eq 1 ]] && pac_install "${PKG_DEFENSE[@]}"
  [[ $WANT_CRYPTO -eq 1 ]] && pac_install "${PKG_CRYPTO[@]}"
  [[ $WANT_VISUAL -eq 1 ]] && pac_install "${PKG_VISUAL[@]}"
  section "AUR PACKAGES"
  if ensure_yay; then run yay -S --needed --noconfirm "${AUR_PKGS[@]}" || warn "Some AUR packages failed (non-fatal)."; else warn "No AUR helper — skipping: ${AUR_PKGS[*]}"; fi
  # Oh My Zsh + Powerlevel10k (prompt theme referenced by .zshrc)
  if [[ ! -d "$HOME/.oh-my-zsh" && $DRY -eq 0 ]]; then
    info "Installing Oh My Zsh + Powerlevel10k…"
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || warn "Oh My Zsh install failed (deck still works with plain zsh fallback prompt)."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" 2>/dev/null || true
  fi
fi

if [[ $WANT_PIP -eq 1 && "$MODE" != "configs" ]]; then
  section "PYTHON DEPENDENCIES (TUI)"
  if [[ $DRY -eq 1 ]]; then info "[dry-run] pip install -r tui/requirements.txt into ~/.cyberdeck/venv"
  elif have python3; then
    python3 -m venv "$DECK/venv" 2>/dev/null && "$DECK/venv/bin/pip" install -q --upgrade pip && "$DECK/venv/bin/pip" install -q -r "$REPO_DIR/tui/requirements.txt" \
      && ok "TUI venv ready ($DECK/venv)" \
      || { warn "venv pip install failed — falling back to pip --user"; python3 -m pip install --user -q textual rich requests psutil colorama || warn "pip failed; TUI will use dialog/rich fallbacks available."; }
    # Wrapper so `cyberdeck` always finds the venv python
    mkdir -p "$DECK/bin"; printf '#!/usr/bin/env bash\nexec "%s/venv/bin/python"\n' "$DECK" >"$DECK/bin/cyberdeck-python"; chmod +x "$DECK/bin/cyberdeck-python"
  fi
fi

# ── 3. Directory skeleton ─────────────────────────────────────────────────
section "CYBERDECK HOME (~/.cyberdeck)"
run mkdir -p "$DECK"/{logs,sessions,captures,wordlists,notes,targets,reports,backups,vpn,bin,lib,scripts,dashboards,tui/modules,wallpapers,sounds}
[[ -f "$DECK/theme" ]] || run bash -c 'echo ghost >"$1"' _ "$DECK/theme"
[[ -f "$DECK/api-keys" ]] || run bash -c 'printf "# Cyberdeck API keys — chmod 600, never commit\n# SHODAN_API_KEY=\n# HUNTER_API_KEY=\n" >"$1"; chmod 600 "$1"' _ "$DECK/api-keys"

# ── 4. Backup existing configs, then install new ones ────────────────────
install_file() { # src dest
  local src="$1" dest="$2"
  if [[ -e "$dest" && ! -L "$dest" ]]; then run mkdir -p "$BACKUP_DIR$(dirname "$dest")"; run cp -a "$dest" "$BACKUP_DIR$dest"; fi
  run mkdir -p "$(dirname "$dest")"; run cp -a "$src" "$dest"
}
install_dir() { # srcdir destdir
  local src="$1" dest="$2" f
  [[ -d "$src" ]] || return 0
  while IFS= read -r -d '' f; do install_file "$f" "$dest/${f#"$src"/}"; done < <(find "$src" -type f -print0)
}
section "CONFIG DEPLOYMENT (backups → $BACKUP_DIR)"
install_dir "$REPO_DIR/config/i3"       "$HOME/.config/i3"
install_dir "$REPO_DIR/config/polybar"  "$HOME/.config/polybar"
install_dir "$REPO_DIR/config/picom"    "$HOME/.config/picom"
install_dir "$REPO_DIR/config/alacritty" "$HOME/.config/alacritty"
install_dir "$REPO_DIR/config/rofi"     "$HOME/.config/rofi"
install_dir "$REPO_DIR/config/dunst"    "$HOME/.config/dunst"
install_dir "$REPO_DIR/config/neofetch" "$HOME/.config/neofetch"
install_dir "$REPO_DIR/config/ranger"   "$HOME/.config/ranger"
install_dir "$REPO_DIR/config/gtk"      "$HOME/.config/gtk-3.0-home"
# gtk layout: settings.ini belongs in ~/.config/gtk-3.0/, gtk-3.0/* merged there
run mkdir -p "$HOME/.config/gtk-3.0"
install_file "$REPO_DIR/config/gtk/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
install_file "$REPO_DIR/config/gtk/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
run rm -rf "$HOME/.config/gtk-3.0-home"
install_file "$REPO_DIR/config/tmux/tmux.conf" "$HOME/.tmux.conf"
install_file "$REPO_DIR/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
install_file "$REPO_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
install_file "$REPO_DIR/config/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
install_dir  "$REPO_DIR/config/zsh/aliases" "$HOME/.config/zsh/aliases"
install_file "$REPO_DIR/config/vim/.vimrc" "$HOME/.vimrc"
install_dir  "$REPO_DIR/widgets/conky" "$HOME/.config/conky"
install_dir  "$REPO_DIR/widgets/cava"  "$HOME/.config/cava"
ok "Configs deployed."

section "SCRIPTS · LIBS · DASHBOARDS · TUI"
install_dir "$REPO_DIR/lib" "$DECK/lib"
install_dir "$REPO_DIR/scripts" "$DECK/scripts"
install_dir "$REPO_DIR/dashboards" "$DECK/dashboards"
install_file "$REPO_DIR/tui/cyberdeck-tui.py" "$DECK/tui/cyberdeck-tui.py"
install_file "$REPO_DIR/tui/requirements.txt" "$DECK/tui/requirements.txt"
install_dir "$REPO_DIR/tui/modules" "$DECK/tui/modules"
# Main command + helpers, plus bare-name symlinks for every module
for b in "$REPO_DIR/bin/"*; do install_file "$b" "$DECK/bin/$(basename "$b")"; done
run find "$DECK/scripts" "$DECK/dashboards" "$DECK/bin" "$HOME/.config/polybar" "$HOME/.config/i3/scripts" "$HOME/.config/conky" -name '*.sh' -exec chmod +x {} +
run chmod +x "$DECK/bin/cyberdeck" "$DECK/bin/cyberdeck-motd" "$DECK/bin/cyberdeck-netdaemon" "$DECK/tui/cyberdeck-tui.py"
run mkdir -p "$HOME/.local/bin"; run ln -sf "$DECK/bin/cyberdeck" "$HOME/.local/bin/cyberdeck"
ok "$(find "$REPO_DIR/scripts" -name '*.sh' | wc -l) modules installed (on PATH via .zshrc)."

# ── 5. Fonts ──────────────────────────────────────────────────────────────
if [[ $WANT_FONTS -eq 1 ]]; then
  section "FONTS"
  if fc-list 2>/dev/null | grep -qi 'JetBrainsMono.*Nerd'; then ok "JetBrainsMono Nerd Font present."
  elif [[ $DRY -eq 1 ]]; then info "[dry-run] download JetBrainsMono Nerd Font"
  else
    info "Downloading JetBrainsMono Nerd Font (official Nerd Fonts release)…"
    mkdir -p "$HOME/.local/share/fonts"; tmp="$(mktemp -d)"
    if curl -fsSL -o "$tmp/jb.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" && (cd "$tmp" && unzip -qo jb.zip -d "$HOME/.local/share/fonts"); then ok "Font installed."; else warn "Font download failed — install ttf-jetbrains-mono-nerd via pacman instead."; fi
    rm -rf "$tmp"
  fi
  run fc-cache -f >/dev/null 2>&1
fi

# ── 6. Wallpapers & sounds ────────────────────────────────────────────────
section "WALLPAPERS & SOUNDS"
install_dir "$REPO_DIR/sounds" "$DECK/sounds"
if ls "$REPO_DIR/themes/wallpapers/"*.png >/dev/null 2>&1; then install_dir "$REPO_DIR/themes/wallpapers" "$DECK/wallpapers"; fi
if [[ $DRY -eq 0 ]] && have python3; then
  info "Generating 1920×1080 wallpapers for all 4 themes…"
  python3 "$REPO_DIR/themes/wallpapers/generate-wallpapers.py" "$DECK/wallpapers" 1920 1080 || warn "Wallpaper generation failed (repo PNGs already copied)."
  python3 "$REPO_DIR/sounds/generate-sounds.py" "$DECK/sounds" >/dev/null 2>&1 || true
fi
ok "Media ready: $DECK/wallpapers · $DECK/sounds"

# ── 7. Shell & session defaults ───────────────────────────────────────────
section "SESSION DEFAULTS"
if [[ "$MODE" != "configs" && $DRY -eq 0 ]]; then
  if [[ "$SHELL" != */zsh ]] && confirm "Set zsh as your default shell?"; then chsh -s "$(command -v zsh)" && ok "Default shell → zsh (effective next login)."; fi
  # .xinitrc for startx users; display managers pick i3 from the session list
  if [[ ! -f "$HOME/.xinitrc" ]] || confirm "Write ~/.xinitrc launching i3 (for startx)?"; then
    printf '# Cyberdeck session\n[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources\nexec i3\n' >"$HOME/.xinitrc"; ok ".xinitrc → exec i3"
  fi
fi
mkdir -p "$HOME/.config/gtk-3.0"; printf 'file://%s/.cyberdeck Cyberdeck\nfile://%s/Documents Documents\n' "$HOME" "$HOME" >"$HOME/.config/gtk-3.0/bookmarks" 2>/dev/null || true

# ── 8. Summary ────────────────────────────────────────────────────────────
section "DEPLOYMENT COMPLETE"
ok "Cyberdeck installed. Config backup: $BACKUP_DIR"
cat <<SUM

  ┌─[ QUICK START ]──────────────────────────────────────────────────┐
  │  Log out → choose i3 session (or run: startx)                    │
  │  Super+F1  Mission Control      Super+d   Launcher               │
  │  Super+n   LAN scan             cyberdeck help  All commands     │
  │  Docs: $REPO_DIR/README.md                                        │
  │  Uninstall: $REPO_DIR/uninstall.sh                                │
  └──────────────────────────────────────────────────────────────────┘
SUM
if [[ -n "${DISPLAY:-}" ]] && confirm "Launch Mission Control now (in this terminal)?"; then exec "$DECK/bin/cyberdeck"; fi
if confirm "Reboot now to enter the deck cleanly?"; then run systemctl reboot; fi
ok "◢ DECK ONLINE. Stay legal: only test systems you own or are authorised to test."
