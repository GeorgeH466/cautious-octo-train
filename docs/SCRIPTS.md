# ▤ SCRIPTS — Module Index (76 modules)

Every module: styled banner · `--help` · dependency check with install offer ·
logs to `~/.cyberdeck/logs/` · reports to `~/.cyberdeck/reports/` · callable by bare name on PATH.
Shared libraries: `lib/colors.sh` (themes), `lib/ui.sh` (banners/tables/bars), `lib/utils.sh` (logging/deps/network helpers).


## network

| Module | What it does |
|---|---|
| `arp-spoof-detect` | ARP spoofing / MITM detection on the LAN |
| `bandwidth-test` | Internet & LAN bandwidth testing |
| `dns-enum` | DNS enumeration — records, zone transfer, brute subdomains |
| `dns-spoof-detect` | DNS spoofing / poisoning detection |
| `firewall-manager` | iptables / nftables / ufw rule manager |
| `mac-changer` | MAC address randomizer / restorer |
| `net-discover` | ARP-based live host discovery |
| `net-scan` | Full network scanner — nmap wrapper with formatted output |
| `net-shares` | SMB / NFS network share enumerator |
| `packet-capture` | tcpdump/tshark capture wrapper with BPF filters |
| `port-scan` | Quick/full port scan with service detection |
| `sniff-creds` | Cleartext credential spotting — EDUCATIONAL (own traffic only) |
| `subnet-calc` | Subnet calculator (CIDR math, ranges, splits) |
| `tor-manager` | Tor service manager with circuit / exit display |
| `traceroute-visual` | Visual traceroute with per-hop geolocation |
| `traffic-monitor` | Real-time traffic monitoring (iftop / nethogs / ss) |
| `vpn-manager` | OpenVPN / WireGuard connection manager |
| `wifi-deauth` | 802.11 deauthentication — EDUCATIONAL, own network only |
| `wifi-monitor` | Enable / disable Wi-Fi monitor mode |
| `wifi-scan` | Wireless network scanner with signal strength |

## recon

| Module | What it does |
|---|---|
| `email-harvest` | Email address harvester for a domain |
| `google-dork` | Google dork query builder (opens or prints queries) |
| `header-analyze` | HTTP security header analyzer with grading |
| `osint-lookup` | OSINT aggregator — IP/domain/user/email in one pass |
| `shodan-query` | Shodan search wrapper (API key in ~/.cyberdeck/api-keys) |
| `social-recon` | Username presence checker across platforms |
| `ssl-analyze` | SSL/TLS certificate & cipher analyzer |
| `subdomain-enum` | Subdomain enumeration (crt.sh + brute + tools) |
| `wayback-fetch` | Wayback Machine URL & snapshot fetcher |
| `web-tech-detect` | Website technology / WAF fingerprinting |
| `whois-lookup` | Enhanced whois with clean formatting |

## exploit

| Module | What it does |
|---|---|
| `brute-force` | Online brute-force wrapper — hydra / medusa / ncrack |
| `exploit-search` | SearchSploit / ExploitDB wrapper with clean output |
| `hash-crack` | Hash cracker — hashcat / john wrapper with auto mode select |
| `payload-gen` | Payload generator — msfvenom wrapper + listener helper |
| `reverse-shell-gen` | Reverse shell one-liner generator (all languages) |
| `sqli-test` | SQL injection tester — sqlmap wrapper (safe defaults) |
| `vuln-scan` | Vulnerability scanner — nuclei + nikto + nmap NSE orchestrator |
| `wordlist-manager` | Wordlist downloader & manager (~/.cyberdeck/wordlists) |
| `xss-scan` | Cross-site scripting scanner (reflected, via payload reflection) |

## defense

| Module | What it does |
|---|---|
| `backup-manager` | Encrypted backup manager (tar + GPG/age) |
| `connection-monitor` | Active connection monitor with new-connection alerts |
| `integrity-check` | File integrity checker — baseline & verify critical paths |
| `log-analyzer` | Log file analyzer — auth failures, errors, top talkers |
| `process-monitor` | Suspicious process hunter (deleted exes, odd parents, miners) |
| `rootkit-check` | Rootkit detection — rkhunter + chkrootkit + heuristics |
| `system-harden` | Interactive system hardening checklist & applier |

## crypto

| Module | What it does |
|---|---|
| `decrypt-file` | File decryption — age / GPG auto-detect |
| `encrypt-file` | File encryption — age (preferred) or GPG symmetric/asymmetric |
| `hash-file` | File hashing — MD5/SHA1/SHA256/SHA512/BLAKE2 + verify |
| `key-manager` | GPG & age key management |
| `password-gen` | Secure password & passphrase generator (CSPRNG) |
| `steganography` | Hide / extract data in images & audio (steghide + binwalk) |

## system

| Module | What it does |
|---|---|
| `cleanup` | System cleanup — pacman cache, journals, temp, trash, orphans |
| `disk-analyzer` | Disk usage analyzer — big files, growth, SMART hints |
| `hardware-probe` | Hardware detection — CPU/GPU/USB/PCI/battery/sensors |
| `resource-monitor` | Live resource monitor (htop alternative with HUD bars) |
| `service-manager` | Systemd service manager with cyberdeck presets |
| `system-info` | Detailed system information report |
| `update-all` | Update system, AUR, pip tools & cyberdeck itself |
| `usb-monitor` | USB device monitor with plug alerts + history |

## ui

| Module | What it does |
|---|---|
| `ascii-banner` | ASCII art banner generator (figlet/toilet/pyfiglet fallback) |
| `boot-splash` | Cyberdeck 'system initialization' boot splash animation |
| `dashboard` | Launch a tmux operational dashboard by name |
| `hex-dump-visual` | Colourised visual hex dump (entropy & string highlights) |
| `layout-switcher` | Switch i3 workspace layouts (ops layouts in config/i3/workspace-layouts) |
| `lock-screen` | Sci-fi lock screen (i3lock-color with HUD ring & blur) |
| `matrix-rain` | Matrix digital rain for the terminal (cmatrix / unimatrix / built-in) |
| `theme-switcher` | Hot-swap colour themes — Ghost / Matrix / Amber / Blood |

## cyberdeck

| Module | What it does |
|---|---|
| `cheatsheet` | Interactive cheatsheet — commands for every tool category |
| `log-viewer` | Centralized cyberdeck + system log viewer with filtering |
| `mission-control` | Main cyberdeck control panel (dialog TUI → Python TUI) |
| `quick-launch` | Quick-launch menu for frequent tasks (rofi or fzf or numbered) |
| `session-manager` | Save / restore named tmux 'mission' sessions |
| `status-board` | Full status board — system, network, threat posture at a glance |
| `toolkit-menu` | Categorized launcher for every cyberdeck module |

## Dashboards (tmux)

| Command | Layout |
|---|---|
| `cyberdeck dashboard main` | status-board · resource monitor · live logs · launcher shell |
| `cyberdeck dashboard network` | packet capture · traffic · connections · ARP/DNS spoof checks |
| `cyberdeck dashboard recon` | target console · scan results · OSINT · notes editor |
| `cyberdeck dashboard defense` | auth log tail · connection watch · process hunter · hardening |
| `cyberdeck dashboard crypto` | encrypt · hash/crack · key manager · stego/hex |

## The `cyberdeck` command

```
cyberdeck                        Mission Control TUI
cyberdeck dashboard [name]       main|network|recon|defense|crypto
cyberdeck scan [target] [mode]   quick nmap (net-scan)
cyberdeck discover [subnet]      LAN host discovery
cyberdeck tools                  list all 76 modules
cyberdeck menu [category]        categorised launcher
cyberdeck theme [name]           ghost|matrix|amber|blood
cyberdeck status [--watch]       full status board
cyberdeck logs [src] [filter]    central log viewer
cyberdeck cheat [topic]          cheatsheets
cyberdeck lock · update · splash · version · help
cyberdeck <module> [args…]       pass-through to any module
```

## Conventions

- **Exit codes**: 0 success · 1 usage/dependency/fatal · tool exit codes propagate where wrapped.
- **Interactive + scriptable**: missing args prompt on a TTY; pass args for non-interactive use.
  `CYBERDECK_YES=1` auto-confirms prompts (use with care), `NO_COLOR=1` disables colour.
- **Authorised use**: network/exploit modules print the legal warning box and many ask for explicit confirmation. See README disclaimer.
