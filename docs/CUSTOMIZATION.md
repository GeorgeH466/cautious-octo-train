# 🎨 CUSTOMIZATION — Themes, Layouts, Widgets

## Colour themes (hot-swappable)

```bash
theme-switcher            # interactive (rofi in X, menu in TTY)
theme-switcher matrix     # direct: ghost | matrix | amber | blood
cyberdeck theme amber
```

| Theme | Palette | Vibe |
|---|---|---|
| **Ghost** (default) | `#00fff5` cyan / white on `#0a0a0a` | Tron command deck |
| **Matrix** | `#00ff41` green on black | Digital rain console |
| **Amber** | `#ffb000` amber on `#140e04` | Retro amber terminal |
| **Blood** | `#ff0040` red on black | Red-alert battle mode |

What switching updates automatically: shell/TUI colours (via
`~/.cyberdeck/theme` + `lib/colors.sh`), Alacritty primary colours, Polybar
(restart), Dunst (restart), `~/.cyberdeck/current-theme.env` for your own
scripts, and an i3 reload hook. Wallpaper to match:
`feh --bg-fill ~/.cyberdeck/wallpapers/matrix-grid.png`.

**Make your own theme:** copy a file in `themes/colorschemes/` (e.g.
`ghost.env` → `void.env`), edit the hex values, add a matching `case` arm in
`lib/colors.sh`, and a wallpaper entry in
`themes/wallpapers/generate-wallpapers.py` (`THEMES` dict), then regenerate:
`python3 themes/wallpapers/generate-wallpapers.py ~/.cyberdeck/wallpapers`.

## Wallpapers

Procedural, dependency-free generator (pure stdlib PNG writer):

```bash
python3 themes/wallpapers/generate-wallpapers.py [outdir] [w h]   # default 1920×1080
```

Each theme gets `-grid.png` (perspective Tron grid + horizon beam) and
`-circuit.png` (random Manhattan circuit traces). i3 picks randomly from
`~/.cyberdeck/wallpapers/` at login.

## Workspace layouts

`config/i3/workspace-layouts/*.json` are standard `i3-save-tree` layouts.
Apply with `layout-switcher network` (loads layout + spawns its apps).
Capture your own: arrange windows, then
`i3-save-tree --workspace N > ~/.config/i3/workspace-layouts/mine.json`
(edit per i3 docs: remove `//` comments on swallow criteria).

## Polybar HUD

Two bars in `config/polybar/config.ini`: `cyber-top` (ops) and
`cyber-bottom` (vitals). Custom modules live in `config/polybar/scripts/` —
each is a tiny script printing one line; copy one to add your own (e.g. a
stock ticker) and register it as `type = custom/script`.

Hide the bottom bar: comment its launch in `config/polybar/launch.sh`.
Toggle anytime: `Super+b`.

## Conky widgets

`widgets/conky/*.conf`, started by `~/.config/conky/start-conky.sh` from i3.
Disable one by removing it from that script's list. Move a widget by editing
`alignment`/`gap_x`/`gap_y`. Transparency is `own_window_argb_value`
(0=clear … 255=solid).

## Terminal CRT feel

- Everyday: Alacritty 88% opacity + picom dual-kawase blur + 10px rounded corners.
- Full retro (real scanlines/curvature): run `cool-retro-term` (alias `crt`).
- Tune blur/opacity in `config/picom/picom.conf` (`blur-strength`, `opacity-rule`).

## Fonts & icons

JetBrainsMono Nerd Font everywhere (fallbacks: FiraCode/Hack Nerd). Change in
`config/i3/config` (`font pango:…`), `config/alacritty/alacritty.toml`,
`config/polybar/config.ini` (`font-0/1`) and `config/gtk/settings.ini`.
Icons: Papirus-Dark; cursors: Capitaine (see `themes/cursors/README.md`).

## MOTD & boot splash

Every interactive shell shows the cyberdeck MOTD (`bin/cyberdeck-motd`):
logo, vitals, module count, rotating security tip. Full boot splash plays
once per day. Silence with `export CYBERDECK_NO_MOTD=1` in your shell rc.

## API keys

Put optional keys in `~/.cyberdeck/api-keys` (chmod 600, auto-sourced):
`SHODAN_API_KEY=…` enables `shodan-query`; `HUNTER_API_KEY=…` for email OSINT.
Never commit this file.
