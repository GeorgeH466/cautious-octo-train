#!/usr/bin/env bash
# run-tests.sh — Cyberdeck-BlackArch validation suite (no root, no network needed)
# Checks: bash syntax · python compile · layout JSON · structure inventory ·
#         --help on every module · live smoke tests of safe modules.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; cd "$ROOT"
PASS=0 FAIL=0
ok() { PASS=$((PASS+1)); printf '  [✔] %s\n' "$1"; }
bad() { FAIL=$((FAIL+1)); printf '  [✖] %s\n' "$1"; }

echo "◢ CYBERDECK TEST SUITE — $ROOT"
echo "┌─[ BASH SYNTAX ]"
while IFS= read -r -d '' f; do bash -n "$f" 2>/dev/null && ok "$f" || bad "syntax: $f"; done < <(find scripts dashboards lib bin config widgets tests \( -name '*.sh' -o -name 'cyberdeck-*' \) -print0 2>/dev/null | sort -z)
for f in install.sh uninstall.sh bin/cyberdeck; do bash -n "$f" && ok "$f" || bad "syntax: $f"; done

echo "┌─[ PYTHON COMPILE ]"
while IFS= read -r -d '' f; do python3 -m py_compile "$f" 2>/dev/null && ok "$f" || bad "py_compile: $f"; done < <(find tui themes sounds -name '*.py' -print0)

echo "┌─[ LAYOUT JSON ]"
python3 - <<'PY' && ok "workspace-layout JSON valid" || bad "workspace-layout JSON"
import json, glob
for f in glob.glob("config/i3/workspace-layouts/*.json"): json.load(open(f))
for f in glob.glob("themes/colorschemes/*.json"): json.load(open(f))
PY

echo "┌─[ STRUCTURE INVENTORY ]"
for p in install.sh uninstall.sh README.md LICENSE lib/colors.sh lib/ui.sh lib/utils.sh \
  bin/cyberdeck bin/cyberdeck-motd bin/cyberdeck-netdaemon \
  config/i3/config config/polybar/config.ini config/polybar/launch.sh config/picom/picom.conf \
  config/alacritty/alacritty.toml config/rofi/config.rasi config/dunst/dunstrc \
  config/neofetch/config.conf config/ranger/rc.conf config/tmux/tmux.conf \
  config/zsh/.zshrc config/zsh/.p10k.zsh config/vim/.vimrc config/gtk/settings.ini \
  dashboards/main-dashboard.sh dashboards/network-ops.sh dashboards/recon-dashboard.sh \
  dashboards/defense-dashboard.sh dashboards/crypto-dashboard.sh \
  tui/cyberdeck-tui.py tui/requirements.txt \
  tui/modules/network_panel.py tui/modules/system_panel.py tui/modules/tools_panel.py \
  tui/modules/recon_panel.py tui/modules/log_panel.py \
  widgets/conky/system-monitor.conf widgets/conky/network-monitor.conf widgets/conky/clock-hud.conf \
  widgets/conky/threat-dashboard.conf widgets/conky/hex-rain.conf widgets/cava/config \
  sounds/boot.wav sounds/alert.wav sounds/notification.wav sounds/keystroke.wav \
  docs/KEYBINDINGS.md docs/TOOLS.md docs/SCRIPTS.md docs/CUSTOMIZATION.md docs/TROUBLESHOOTING.md; do
  [[ -f "$p" ]] && ok "exists: $p" || bad "MISSING: $p"
done
N=$(find scripts -name '*.sh' | wc -l); [[ "$N" -eq 76 ]] && ok "76 modules present" || bad "module count = $N (expected 76)"
W=$(ls themes/wallpapers/*.png 2>/dev/null | wc -l); [[ "$W" -ge 8 ]] && ok "$W wallpapers present" || bad "wallpapers = $W (expected ≥8)"
[[ -x install.sh && -x bin/cyberdeck ]] && ok "entry points executable" || bad "entry points not executable"

echo "┌─[ --help ON EVERY MODULE (fake HOME) ]"
FAKE="$(mktemp -d)"; mkdir -p "$FAKE/.cyberdeck"
cp -r lib "$FAKE/.cyberdeck/lib"
export HOME="$FAKE"
while IFS= read -r -d '' f; do
  timeout 10 bash "$f" --help >/dev/null 2>&1 && ok "help: $(basename "$f")" || bad "help FAILED: $f"
done < <(find scripts -name '*.sh' -print0 | sort -z)

echo "┌─[ LIVE SMOKE TESTS ]"
bin/cyberdeck version >/dev/null 2>&1 && ok "cyberdeck version" || bad "cyberdeck version"
bin/cyberdeck tools >/dev/null 2>&1 && ok "cyberdeck tools" || bad "cyberdeck tools"
bash scripts/network/subnet-calc.sh 10.0.0.0/24 2>/dev/null | grep "192\|10.0.0" >/dev/null && ok "subnet-calc computes" || bad "subnet-calc"
bash scripts/crypto/hash-file.sh README.md 2>/dev/null | grep -i "sha256" >/dev/null && ok "hash-file computes SHA256" || bad "hash-file"
bash scripts/crypto/password-gen.sh 12 1 2>/dev/null | grep "▸" >/dev/null && ok "password-gen generates" || bad "password-gen"
bash scripts/cyberdeck/cheatsheet.sh tmux 2>/dev/null | grep -i "prefix" >/dev/null && ok "cheatsheet renders" || bad "cheatsheet"
bash scripts/ui/ascii-banner.sh TEST 2>/dev/null | grep "TEST" >/dev/null && ok "ascii-banner renders" || bad "ascii-banner"
python3 tui/cyberdeck-tui.py --help >/dev/null 2>&1 && ok "tui --help" || bad "tui --help"
python3 -c "import sys; sys.path.insert(0,'tui/modules'); import tools_panel; assert sum(len(v) for v in tools_panel.discover_tools().values())==76" && ok "TUI discovers 76 tools" || bad "TUI tool discovery"
python3 sounds/generate-sounds.py "$FAKE/snd" >/dev/null 2>&1 && [[ -f "$FAKE/snd/boot.wav" ]] && ok "sound generator" || bad "sound generator"
python3 themes/wallpapers/generate-wallpapers.py "$FAKE/wp" 320 180 >/dev/null 2>&1 && [[ -f "$FAKE/wp/ghost-grid.png" ]] && ok "wallpaper generator" || bad "wallpaper generator"
rm -rf "$FAKE"

echo "└── RESULT: $PASS passed · $FAIL failed"
[[ $FAIL -eq 0 ]]
