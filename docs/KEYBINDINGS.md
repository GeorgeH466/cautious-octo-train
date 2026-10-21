# ⌨ KEYBINDINGS — Cyberdeck-BlackArch

`Super` = Windows/⌘ key (Mod4). Everything is keyboard-driven; there are no desktop icons.

## Core

| Keys | Action |
|---|---|
| `Super+Enter` | Terminal (Alacritty) |
| `Super+Shift+Enter` | Terminal attached to tmux session `deck` |
| `` Super+` `` | Toggle floating scratchpad terminal |
| `Super+d` | Rofi app launcher |
| `Super+Shift+d` | Rofi **module launcher** (all 76 cyberdeck scripts) |
| `Super+Shift+f` | Ranger file manager |
| `Super+Shift+b` | Firefox |
| `Super+p` | Power menu (lock/reboot/shutdown…) |
| `Super+Shift+q` | Close window |
| `Super+Shift+e` | Exit i3 (with confirm) |
| `Super+Shift+c` / `r` | Reload config / restart i3 in place |

## Cyberdeck operations

| Keys | Action |
|---|---|
| `Super+F1` | **Mission Control TUI** |
| `Super+F2` | Network Ops dashboard (→ ws 2) |
| `Super+F3` | Recon dashboard (→ ws 4) |
| `Super+F4` | Defense dashboard (→ ws 6) |
| `Super+F5` | Crypto dashboard (→ ws 7) |
| `Super+n` | LAN discovery + quick scan |
| `Super+m` | Toggle cava audio visualizer |
| `Super+b` | Toggle Polybar HUD |
| `Super+Shift+t` | Theme switcher |
| `Super+Shift+m` | Matrix rain |
| `Super+Shift+l` | Sci-fi lock screen |
| `Super+Shift+s` / `Print` | Screenshot (select / full) → bordered PNG + clipboard |
| `Super+g` | Toggle window gaps |

## Windows & workspaces

| Keys | Action |
|---|---|
| `Super+1…0` | Workspaces 1–10 (mission bays) |
| `Super+Shift+1…0` | Move window to workspace |
| `Super+Tab` | Previous workspace (back-and-forth) |
| `Super+,` / `Super+.` | Prev / next workspace |
| `Super+h/j/k/l` or arrows | Focus direction |
| `Super+Shift+h/j/k/l` | Move window |
| `Super+f` | Fullscreen |
| `Super+Shift+Space` | Toggle floating |
| `Super+Space` | Focus floating/tiling toggle |
| `Super+s` / `w` / `e` | Stacking / tabbed / toggle split layout |
| `Super+v` / `Super+Shift+v` | Split vertical / horizontal |
| `Super+a` | Focus parent container |
| `Super+r` then `h/j/k/l` | Resize mode (`Esc` exits) |

### Workspaces (mission bays)

| # | Bay | Auto-assigned apps |
|---|---|---|
| 1 | ◢ MAIN | Main dashboard (auto-started) |
| 2 | ◈ NET | Wireshark |
| 3 | ◎ WEB | Firefox/Chromium/Brave |
| 4 | ⌖ RECON | — |
| 5 | ⚔ EXPLOIT | Burp Suite / OWASP ZAP |
| 6 | ⛨ DEFENSE | — |
| 7 | ⚿ CRYPTO | KeePassXC |
| 8 | ▤ FILES | — (Ranger) |
| 9 | ✉ COMMS | Thunderbird/Discord/Telegram/Signal |
| 10 | ⚙ SYS | pavucontrol/blueman/lxappearance |

## Media / hardware

Volume keys (+ dunst level popup), `playerctl` play/next/prev, brightness keys via `brightnessctl`.

## tmux (prefix = `Ctrl-a`)

| Keys | Action |
|---|---|
| `prefix \|` / `prefix -` | Split vertical / horizontal (keeps cwd) |
| `prefix h/j/k/l` | Move between panes |
| `prefix H/J/K/L` | Resize pane |
| `prefix c` / `prefix Ctrl-h/l` | New window / prev-next window |
| `prefix z` | Zoom pane |
| `prefix [` then `v`,`y` | Copy mode → yank to system clipboard |
| `prefix M/N/R/D` | Open Main/Network/Recon/Defense dashboard sessions |
| `prefix r` | Reload tmux config |
| `prefix d` | Detach (`tmux attach` to return) |

## Mission Control TUI

`1–5` switch tabs · `/` search tools · `r` refresh · `?` help · `q` quit.
In Tools tab: select a row, type args, `Enter` runs with captured output.

## Vim (leader = `Space`)

`<leader>w/q/x` save/quit · `<leader>e` file explorer · `<leader>s/v` splits ·
`Ctrl-h/j/k/l` window nav · `Tab` next buffer · `:ShellCheck`, `:JsonFmt` helpers.
