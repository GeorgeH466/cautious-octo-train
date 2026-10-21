# cyberdeck-blackarch

```
   ██████╗██╗   ██╗██████╗ ███████╗██████╗ ██████╗ ███████╗ ██████╗██╗  ██╗
  ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝██║ ██╔╝
  ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝██║  ██║█████╗  ██║     █████╔╝
  ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗██║  ██║██╔══╝  ██║     ██╔═██╗
  ╚██████╗   ██║   ██████╔╝███████╗██║  ██║██████╔╝███████╗╚██████╗██║  ██╗
   ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝
        ◢  TRON × MR. ROBOT × GHOST IN THE SHELL — BUT EVERYTHING WORKS  ◣
```

[![License: MIT](https://img.shields.io/badge/License-MIT-00fff5.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-BlackArch%20%2F%20Arch%20x86__64-0a0a0a)
![Modules](https://img.shields.io/badge/modules-76-00ff41)
![WM](https://img.shields.io/badge/WM-i3--gaps-00b8b0)

**Cyberdeck-BlackArch** transforms a stock [BlackArch Linux](https://blackarch.org)
(or any Arch-based) install into a complete cyberdeck operations environment:
a sci-fi HUD desktop (i3-gaps + Polybar + Picom blur), a tabbed **Mission
Control** terminal, five purpose-built tmux dashboards, **76 themed modules**
wrapping the BlackArch arsenal (network, recon, exploit, defense, crypto,
system), four hot-swappable colour themes, procedurally generated wallpapers
and sounds — all deployed by one `./install.sh` on any standard x86_64 PC.
No special hardware; a Wi-Fi adapter that supports monitor mode is the only
optional extra (for the wireless-auditing modules).

> ⚠️ **Responsible use:** this is a dual-use security toolkit for education,
> defence, and **authorised** penetration testing. Only scan/attack systems
> you own or have explicit written permission to test. See [Disclaimer](#-disclaimer).

---

## 📺 What it looks like (screenshot descriptions)

### 1 · The Desktop (Workspace 1, ◢ MAIN)
Deep-black `#0a0a0a` Tron-grid wallpaper with a glowing horizon beam.
Translucent (88%) terminals with thin 1px cyan borders float over dual-kawase
blur, 10px gaps, rounded corners. Top Polybar = spaceship HUD: workspace
chips `1:◢ MAIN … 10:⚙ SYS`, centred clock, and live `⛨ THREAT:LOW ·
VPN○ · TOR○ · eth0 IP · ♪ vol · ⚡ battery`. Bottom bar: CPU/RAM/disk block
gauges (`▓▓░░`), live net speed, connection count, update badge. Conky
holograms hug the edges: system monitor (top-right), chrono HUD (top-left),
network graphs, threat dashboard, hex-stream ambient widget.

```
┌─ 1:◢MAIN 2:◈NET … ────── ◢ 2026-10-21 │ 21:47:03 ────── ⛨LOW VPN○ TOR○ ♪80% ┐
│ ┌─ ◢ CHRONO ─┐   ╭─ mission-control ─────────────╮   ┌─ SYSTEM MONITOR ─┐ │
│ │   21:47     │   │ CPU ▓▓▓░░░░ 34%               │   │ CPU  ▓▓▓░░ 34%   │ │
│ └─────────────┘   │ NET ● 192.168.1.42            │   └──────────────────┘ │
│                   ╰───────────────────────────────╯                        │
└─ CPU ▓▓░░ RAM ▓▓▓░ ─── ▼ 812K ▲ 96K ─── ⬢ 14 conn · ⟳ current ───────────┘
```

### 2 · Mission Control TUI (`cyberdeck`, `Super+F1`)
Full-screen tabbed console: **OPS** (live system + network panels),
**TOOLS** (fuzzy-search all 76 modules, run with args, captured output),
**RECON** (target book + quick lookup), **LOGS** (filterable feed),
**MISSIONS** (curated module chains). Falls back to a Rich HUD, then to
dialog menus, so it works before/without pip packages.

### 3 · Dashboards (`cyberdeck dashboard …`)
Four-pane tmux war-rooms. *Network Ops*: live tcpdump stream, traffic
monitor, connection watcher alerting on new endpoints, ARP/DNS spoof checks.
*Defense*: auth-log tail, process hunter, hardening score. Each pane is a
real running tool, not a mock-up.

### 4 · Lock screen (`Super+Shift+L`)
Blurred screenshot of your deck under a neon authentication ring:
`AWAITING INPUT → AUTHENTICATING… / ACCESS DENIED`, 24h HUD clock.

---

## 🚀 Installation

**Requirements:** BlackArch or Arch Linux (x86_64), sudo user, internet for
packages. On other distros the installer still deploys all configs/scripts
(configs-only mode) — install the wrapped tools yourself
([docs/TOOLS.md](docs/TOOLS.md)).

```bash
git clone https://github.com/<your-user>/cyberdeck-blackarch.git
cd cyberdeck-blackarch
./install.sh              # interactive: full / minimal / custom / configs
```

Non-interactive variants:

```bash
./install.sh --full       # everything (several GB of BlackArch tools)
./install.sh --minimal    # core desktop + network/defense/crypto essentials
./install.sh --configs    # dotfiles + scripts + themes only (re-runnable)
./install.sh --dry-run    # print the plan, change nothing
```

What it does: detects BlackArch/Arch → installs package groups via pacman
(+ bootstraps `yay` for AUR extras, with per-package retry so one bad name
never blocks the rest) → installs the Python TUI into `~/.cyberdeck/venv` →
**backs up your existing configs** to `~/.cyberdeck/backups/` → deploys
i3/polybar/picom/alacritty/rofi/dunst/ranger/tmux/zsh/vim/gtk/conky/cava
configs → installs 76 modules as bare commands (`net-scan`, `osint-lookup`, …)
→ fetches/generates fonts, 1920×1080 wallpapers and UI sounds → creates
`~/.cyberdeck/{logs,sessions,captures,wordlists,notes,targets,reports}` →
optionally sets zsh default + writes `.xinitrc`.

Then: **log out → pick the i3 session** (or `startx`). Workspace 1 boots
straight into the main dashboard.

**Uninstall:** `./uninstall.sh` (restores your backed-up configs; `--purge`
also wipes `~/.cyberdeck` data).

---

## ⚡ Quick start

```bash
cyberdeck                    # Mission Control (start here)
cyberdeck status             # one-screen SITREP
cyberdeck discover           # who else is on this LAN?
cyberdeck scan 192.168.1.1   # quick service scan (your router!)
cyberdeck dashboard network  # network war-room
cyberdeck tools              # all 76 modules
net-scan --help              # every module documents itself
cheatsheet nmap              # copy-paste command cards
```

First boot of the day plays the *SYSTEM INITIALIZATION* splash; every new
shell shows the MOTD (vitals + rotating security tip + module count).

### Essential keybindings (full list: [docs/KEYBINDINGS.md](docs/KEYBINDINGS.md))

| Keys | Action |
|---|---|
| `Super+Enter` / `Super+d` | Terminal / app launcher |
| `Super+Shift+d` | Launch any of the 76 modules |
| `Super+F1…F5` | Mission Control / dashboards |
| `Super+n` `Super+m` `Super+b` | LAN scan · cava visualizer · toggle HUD |
| `Super+Shift+l` `Super+Shift+s` | Lock screen · styled screenshot |
| `Super+1…0` | Mission-bay workspaces |

### The `cyberdeck` command

```
cyberdeck                        Mission Control TUI
cyberdeck dashboard [name]       main|network|recon|defense|crypto
cyberdeck scan|discover          quick nmap scan / LAN discovery
cyberdeck tools|menu             module index / categorised launcher
cyberdeck theme [name]           ghost|matrix|amber|blood (hot-swap)
cyberdeck status|logs|cheat      SITREP · log viewer · cheatsheets
cyberdeck lock|update|splash     lock · update everything · boot splash
cyberdeck <any-module> [args]    pass-through, e.g. cyberdeck hash-file x.iso
```

---

## 🧰 Tool & script index

76 modules in 8 categories — full table in **[docs/SCRIPTS.md](docs/SCRIPTS.md)**,
upstream arsenal in **[docs/TOOLS.md](docs/TOOLS.md)**.

| Category | Highlights |
|---|---|
| **network** (20) | `net-scan` `net-discover` `wifi-monitor` `packet-capture` `dns-enum` `arp-spoof-detect` `mac-changer` `vpn-manager` `tor-manager` `firewall-manager` |
| **recon** (11) | `osint-lookup` `subdomain-enum` `web-tech-detect` `ssl-analyze` `header-analyze` (A+–F grading) `wayback-fetch` `shodan-query` |
| **exploit** (9) | `vuln-scan` (nuclei+nikto+NSE) `sqli-test` `xss-scan` `hash-crack` `brute-force` `payload-gen` `reverse-shell-gen` |
| **defense** (7) | `system-harden` (scored audit + fixes) `rootkit-check` `integrity-check` `process-monitor` `connection-monitor` `backup-manager` |
| **crypto** (6) | `encrypt-file`/`decrypt-file` (age⇄GPG) `hash-file` `password-gen` `steganography` `key-manager` |
| **system** (8) | `system-info` `hardware-probe` `usb-monitor` `disk-analyzer` `cleanup` `update-all` `resource-monitor` |
| **ui** (8) | `theme-switcher` `matrix-rain` `hex-dump-visual` `lock-screen` `boot-splash` |
| **cyberdeck** (7) | `mission-control` `status-board` `toolkit-menu` `session-manager` `log-viewer` `cheatsheet` |

Every module shares `lib/colors.sh|ui.sh|utils.sh`: ASCII banner, `--help`,
dependency check with install offer, coloured tables/bars
(`[▓]/[░]/[●]/[○]/[▲]/[✖]/[✔]`), logging to `~/.cyberdeck/logs/`, and
interactive prompts only when args are missing (scriptable otherwise).

## 🎨 Customization

Four themes hot-swap with `theme-switcher` (Ghost cyan · Matrix green ·
Amber · Blood red) across shell, TUI, terminal, bars and notifications.
Layouts, widgets, Polybar modules, fonts and your own themes/wallpapers:
**[docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md)**.

## 📁 Repository structure

```
cyberdeck-blackarch/
├── install.sh · uninstall.sh · README.md · LICENSE
├── bin/          cyberdeck (master command) · MOTD · net watchdog daemon
├── lib/          colors.sh · ui.sh · utils.sh  (shared by all modules)
├── config/       i3 · polybar · picom · alacritty · rofi · dunst
│                 neofetch · ranger · tmux · zsh · vim · gtk
├── scripts/      network/ recon/ exploit/ defense/ crypto/ system/ ui/ cyberdeck/
├── dashboards/   5 tmux war-rooms
├── tui/          cyberdeck-tui.py (Textual + Rich fallback) + modules/
├── widgets/      conky HUDs · cava · screensavers
├── themes/       colorschemes · procedural wallpapers · fonts/icons/cursors notes
├── sounds/       synthesized UI pack (boot/alert/notify/keystroke)
├── docs/         KEYBINDINGS · TOOLS · SCRIPTS · CUSTOMIZATION · TROUBLESHOOTING
└── tests/        run-tests.sh (syntax, structure & smoke tests)
```

## 🧪 Tests

```bash
./tests/run-tests.sh     # bash -n on all scripts, python compile, JSON/YAML-ish
                         # sanity, structure inventory, live smoke tests
```

## 🤝 Contributing

Issues and PRs welcome. Ground rules:

1. **No stubs** — every module must run end-to-end on a real BlackArch box,
   degrade gracefully when its wrapped tool is absent, and support `--help`.
2. Source the shared libs for all output (`ok/warn/err/kv/bar/section`),
   log via `log_msg`, check tools via `check_deps cmd:pkg`.
3. Offensive-capable modules must print `legal_warning` and require an
   explicit confirmation for active actions.
4. Run `./tests/run-tests.sh` before opening a PR; keep `bash -n` clean and
   Python compiling.
5. New theme? Add `themes/colorschemes/<name>.env` + a `lib/colors.sh` case
   arm + a wallpaper palette (see CUSTOMIZATION).

## ⚖️ Disclaimer

This project bundles **wrappers around standard security tools** for
education, system defence, CTFs, and authorised penetration testing.
Running scans, exploits, deauthentication, sniffing or password attacks
against systems you do not own or lack written authorisation to test is
illegal in most jurisdictions (e.g. UK Computer Misuse Act, US CFAA) and is
not endorsed. The authors accept no liability for misuse. You are
responsible for knowing and obeying the laws and rules of engagement that
apply to you. **Deck responsibly.**

## 📜 License

[MIT](LICENSE) © Cyberdeck-BlackArch Contributors. Upstream tools retain
their own licenses.
