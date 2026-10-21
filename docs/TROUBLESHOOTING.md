# 🛠 TROUBLESHOOTING — Cyberdeck-BlackArch

## Installer

| Symptom | Fix |
|---|---|
| "pacman not found" | You're not on Arch/BlackArch. Installer continues in configs-only mode; install tools with your own package manager (see `docs/TOOLS.md`). |
| A package "skipped as unavailable" | Its name differs in your repos, or BlackArch strap isn't added. Add [strap](https://blackarch.org/downloads.html), `pacman -Sy`, retry `./install.sh --minimal`. The bulk-retry logic means one bad name never blocks the rest. |
| yay bootstrap fails | Needs network + `base-devel`. Skip AUR (deck works without it) or install `yay`/`paru` manually and re-run. |
| pip/TUI install fails | Deck falls back to dialog menus. Later: `python3 -m venv ~/.cyberdeck/venv && ~/.cyberdeck/venv/bin/pip install -r tui/requirements.txt`. |
| Ran as root | Don't — run as your user; installer uses sudo where needed. |

## Desktop (i3/polybar/picom)

| Symptom | Fix |
|---|---|
| No bars | `~/.config/polybar/launch.sh`; check `~/.cyberdeck/logs/polybar.log`. Wrong monitor name? launch.sh auto-detects via xrandr; ensure `xorg-xrandr` installed. |
| `Super+b` toggles but bars never return | `pkill polybar; ~/.config/polybar/launch.sh`. |
| No transparency/blur | picom needs a GL-capable driver: `picom --config ~/.config/picom/picom.conf` in a terminal to see errors. VM without 3D accel: set `backend = "xrender"` and remove `blur-method`. |
| Screen tearing | Confirm picom running (`vsync=true`); for NVIDIA also enable ForceFullCompositionPipeline in X config. |
| Wallpaper black | `feh --bg-fill ~/.cyberdeck/wallpapers/ghost-grid.png`; regenerate with `themes/wallpapers/generate-wallpapers.py`. |
| Conky covers windows / wrong spot | Widgets are `own_window_type=desktop` (below windows). Adjust `alignment/gap_*` in the `.conf`; restart via `start-conky.sh`. |
| Lock screen plain black | `i3lock-color` not installed → fallback `i3lock -c 0a0a0a`. Install `i3lock-color` + `scrot` + `ImageMagick` for the blur/HUD ring. |
| Fonts show boxes (□) | Nerd Font missing: `fc-list | grep -i nerd`; install `ttf-jetbrains-mono-nerd` then `fc-cache -f`, restart apps. |

## Tools & scripts

| Symptom | Fix |
|---|---|
| `net-scan: command not found` | Open a **new** zsh (PATH in `.zshrc`), or `export PATH="$HOME/.cyberdeck/bin:$PATH"`. Bare names are symlinks in `~/.cyberdeck/bin` created by install.sh. |
| "cyberdeck lib not found" | Re-run `./install.sh --configs` (installs `lib/` to `~/.cyberdeck/lib`). |
| Module says dependency missing | It offers a pacman install. On non-Arch, install the named tool yourself; names map 1:1 to upstream binaries. |
| Scans need sudo | SYN/OS scans, capture, monitor mode require root/CAP_NET_RAW — modules prompt or use sudo internally; grant caps: `sudo setcap cap_net_raw,cap_net_admin+eip $(which nmap)` (optional). |
| Wi-Fi monitor mode won't restore | `wifi-monitor stop wlan0`, then `sudo systemctl restart NetworkManager`. Some drivers (esp. certain Intel/Realtek) don't support monitor mode at all — check `iw list | grep -A5 'Supported interface modes'`. |
| tmux dashboard "session exists" | That's re-attach by design. Kill with `session-manager kill cyberdeck-main` or `tmux kill-session -t cyberdeck-main`. |
| TUI opens dialog menu instead of Textual | Textual not in the active python. `pip install textual rich` (into `~/.cyberdeck/venv` per installer, which `cyberdeck` auto-uses when present via `cyberdeck-python`). Force modes: `mission-control --dialog`, `cyberdeck-tui.py --rich-fallback`, `--once` for a static summary. |
| `shodan-query` complains about key | Set `SHODAN_API_KEY=` in `~/.cyberdeck/api-keys`. |
| Logs/reports piling up | Everything is under `~/.cyberdeck/{logs,reports,captures}` — prune freely; `cleanup` handles caches. |

## Uninstall / rollback

`./uninstall.sh` stops deck processes, **restores your pre-install configs**
from `~/.cyberdeck/backups/config-backup-*`, removes deck code, and keeps
your data unless `--purge`. Pacman packages are intentionally left installed.

## Getting help

Every module: `<name> --help`. Full command list: `cyberdeck help`.
Cheatsheets: `cheatsheet <nmap|wifi|tmux|i3|gpg|hash|web|linux>`.
Logs for a failing module: `~/.cyberdeck/logs/<module>-YYYYMMDD.log`.
