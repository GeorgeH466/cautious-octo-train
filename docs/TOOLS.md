# ⚔ TOOLS — External Arsenal Reference

Cyberdeck modules are **orchestrators**: they wrap battle-tested upstream tools
with consistent UX, logging and safety rails. This page documents what gets
installed, by group (exactly the groups `install.sh` offers).

> Full/minimal/custom profiles in the installer map to these groups.
> Anything missing at runtime is detected by the module that needs it, with a
> one-keypress pacman install offer (`lib/utils.sh: check_deps`).

## Core desktop (`PKG_CORE`)

| Package | Role on the deck |
|---|---|
| i3-gaps | Tiling WM — 10 mission-bay workspaces |
| polybar | Top/bottom HUD bars |
| picom | Transparency, dual-kawase blur, rounded corners |
| alacritty | GPU terminal (Toml config, 88% opacity) |
| rofi | Launcher + module/power menus |
| dunst | Notifications as "transmissions" |
| ranger | Console file manager (ueberzug previews) |
| tmux | Dashboards, mission sessions |
| zsh + Oh My Zsh + Powerlevel10k | Shell + HUD prompt |
| neofetch · conky · feh · scrot · xclip · xdotool | Sysinfo, widgets, wallpaper, screenshots |
| i3lock-color · xss-lock | Sci-fi lock screen + idle lock |
| dialog · fzf · htop · jq · ImageMagick | TUI fallback, fuzzy launch, proc view, JSON, screenshot borders |
| Papirus icon theme · JetBrainsMono/FiraCode/Hack Nerd Fonts | Icons & glyph-complete fonts |

## Network (`PKG_NET`)

nmap · wireshark-cli (tshark) · tcpdump · aircrack-ng · ettercap · gnu-netcat ·
socat · iftop · nethogs · iw + wireless_tools · macchanger · openvpn ·
wireguard-tools · tor · proxychains-ng · bind (dig) · whois · traceroute ·
mtr · masscan · hping · arp-scan · iperf3

Wrapped by: `net-scan`, `port-scan`, `net-discover`, `wifi-*`, `packet-capture`,
`traffic-monitor`, `dns-*`, `arp-spoof-detect`, `traceroute-visual`,
`mac-changer`, `vpn-manager`, `tor-manager`, `net-shares`, `bandwidth-test`.

## Recon (`PKG_RECON`)

theharvester · recon-ng · sublist3r · amass · whatweb · wafw00f · nikto ·
gobuster · ffuf · nuclei · httpie (+ curl/wget from core)

Wrapped by: `osint-lookup`, `subdomain-enum`, `email-harvest`,
`web-tech-detect`, `vuln-scan`, plus pure-curl modules (`ssl-analyze`,
`header-analyze`, `wayback-fetch`, `shodan-query`, `social-recon`).

> Maltego, Burp Suite and OWASP ZAP are GUI/proprietary-adjacent installs;
> on BlackArch: `sudo pacman -S maltego burpsuite zaproxy` — i3 auto-routes
> Burp/ZAP to workspace 5 (⚔ EXPLOIT). `dirb` is superseded by gobuster/ffuf
> (`sudo pacman -S dirb` if you want it too).

## Exploit (`PKG_EXPLOIT`)

metasploit (msfconsole/msfvenom) · sqlmap · john · hashcat · hydra · medusa ·
searchsploit + exploitdb

Wrapped by: `exploit-search`, `sqli-test`, `brute-force`, `hash-crack`,
`payload-gen`, `reverse-shell-gen`, `xss-scan` (dalfox if present).

## Defense (`PKG_DEFENSE`)

rkhunter · chkrootkit · aide · fail2ban · ufw · clamav · lynis

Wrapped by: `rootkit-check`, `integrity-check` (AIDE when initialised,
SHA-256 baseline otherwise), `system-harden`, `log-analyzer`.

## Crypto (`PKG_CRYPTO`)

gnupg · age · steghide · binwalk · foremost

Wrapped by: `encrypt-file`, `decrypt-file`, `key-manager`, `steganography`,
plus dependency-light `hash-file` / `password-gen`.

## Visual / ambience (`PKG_VISUAL` + AUR)

cava (audio visualizer) · cbonsai · cool-retro-term (true CRT) · cmatrix ·
figlet · AUR: `pipes.sh`, `capitaine-cursors`

## Python (`tui/requirements.txt`, into `~/.cyberdeck/venv`)

textual + rich (Mission Control) · requests · scapy · python-nmap ·
paramiko · beautifulsoup4 · colorama · psutil

## Verifying your arsenal

```bash
cyberdeck tools            # 76 deck modules
pacman -Q | wc -l          # total packages
for t in nmap tshark sqlmap msfconsole hashcat nuclei; do command -v $t; done
```

Every wrapped tool remains fully usable directly — the deck never replaces
upstream CLIs, it accelerates them. `cheatsheet <topic>` is the fast lane.
