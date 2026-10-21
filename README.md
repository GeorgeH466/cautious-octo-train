# ⚔ BlackArch Cyberdeck — Post-Install UI & Command Center (Dual-Boot Edition)

A complete post-install script and interactive **Cyberdeck UI + Menu-Driven Command Center** designed for a **BlackArch Linux Dual-Boot PC**.

It sets up your dual-boot environment, desktop HUD widgets, and launches **`blackarch-deck`** — an all-in-one Cyberdeck UI available in both **Full-Screen Terminal TUI (`curses`)** and **Graphical Desktop/Web Dashboard (`--gui` / `--web`)** modes with **zero external Python pip dependencies** (100% Python 3 standard library, avoiding Arch's PEP-668 `externally-managed-environment` errors).

---

## ✨ What It Gives You

### 1. Live Cyberdeck Telemetry Panels
* **⚡ Hardware & Thermal Sensors**: CPU model, core/thread count, clock speed (MHz), live overall & per-core CPU load bars, CPU temperature (`°C` via `lm_sensors` / `/sys/class/thermal`), GPU hardware & driver detection (`lspci`), RAM & Swap usage bars, and AC/Battery status.
* **⛅ Live Weather Station**: Location-aware weather telemetry (Open-Meteo & `wttr.in` with offline cache fallback) displaying current temperature, "feels like", condition icon, wind speed, humidity, barometric pressure, and 3-day forecast. Switch cities anytime from inside the UI.
* **🕒 Live Cyber-Clock & System Identity**: Real-time digital clock, date, timezone, system uptime, kernel release, load average, package counts, and Dual-Boot RTC clock status (`LOCAL` vs `UTC`).
* **🛡 OPSEC & Network Radar**:
  * Automatic **VPN Tunnel Detector** (`tun0` / `wg0` / `tap0` for HackTheBox, TryHackMe, or Proton/Mullvad VPN).
  * Local interface IPs + Public IP with a **1-click Privacy Mask toggle** (`***.***.***.***`).
  * Live network bandwidth throughput (`↓ RX KB/s` & `↑ TX KB/s`).
  * Active listening local TCP ports (`ss -tln`) and Top CPU/Memory processes.
* **💾 Dual-Boot & Partition Monitor**:
  * Live disk usage across mounted partitions (`/`, `/home`, `/mnt/windows`).
  * Automatic detection of Windows `NTFS` / `BitLocker` / `EFI` partitions via `lsblk`.

### 2. Menu-Driven Command Center (56+ Pre-Loaded + Custom Command Builder)
* **8 Built-in Categories + Favorites & Custom Builder**:
  1. `★ Favorites` — Pin your most-used commands for instant access
  2. `Recon & OSINT` — `nmap` (Quick, Full 65k, Vuln NSE), `rustscan`, `subfinder`, `amass`, `theHarvester`, `dig`/`whois`, `sherlock`
  3. `Web & API` — `whatweb`, `ffuf` (Dir & VHost fuzzing), `gobuster`, `nuclei`, `nikto`, `sqlmap`, `wpscan`, HTTP header inspector
  4. `Wi-Fi & Network` — `arp-scan`, `airmon-ng`, `airodump-ng`, `wifite`, `bettercap`, `responder`, `tcpdump`, local socket inspection
  5. `Exploit & Passwords` — `searchsploit`, `msfconsole`, `rlwrap nc` listener, Reverse Shell 1-liner generator, Python HTTP server, `netexec` (`nxc`), `hydra`, `hashcat` benchmark, `john`
  6. `Forensics & RE` — `ghidra`, `radare2`, `binwalk`, `exiftool`
  7. `OPSEC & VPN` — Public IP/ASN check, `openvpn` tunnel launcher, `macchanger` random MAC spoof, `tor` service starter, history/DNS cleanup
  8. `Dual-Boot & System` — Inspect disks (`lsblk`), Auto-mount Windows NTFS partition to `/mnt/windows`, Fix Windows/Linux dual-boot clock skew (`timedatectl set-local-rtc 1`), Update GRUB with `os-prober`, `pacman -Syu`, BlackArch `strap.sh` bootstrap, list `blackarch-*` tool groups, `sensors`, `btop`, `fastfetch`, clean package cache
* **🎯 Live Engagement Context Variables**:
  * Set `{target}`, `{lhost}`, `{lport}`, `{interface}`, and `{wordlist}` once at the top of the UI — every command in the menu updates in real time with your target and tunnel IP!
* **➕ Custom Command Builder**:
  * Add, edit, favorite, or delete your own commands directly inside the TUI (`a` key) or Graphical UI (`+ Add Custom Command` button), or by editing `~/.config/blackarch-cyberdeck/commands.json`.

---

## 🚀 Quick Start (Run After Installing BlackArch)

Clone this repository on your BlackArch dual-boot PC and run `install.sh`:

```bash
git clone https://github.com/GeorgeH466/cautious-octo-train.git
cd cautious-octo-train
chmod +x install.sh blackarch-deck
./install.sh
```

### Installer Modes
```bash
# Interactive setup (asks whether you want full system/dual-boot setup or UI only)
./install.sh

# Full automated BlackArch dual-boot post-install (Pacman + strap.sh + GRUB os-prober + RTC fix + Conky/Rofi + UI)
./install.sh --all

# Install only the Cyberdeck UI & user configs (no root/sudo required)
./install.sh --ui-only
```

---

## 🖥 Launching the Cyberdeck UI

Once installed, you can launch the UI in whichever mode fits your workflow:

| Command / Alias | Mode | Description |
| :--- | :--- | :--- |
| `blackarch-deck` or `deck` | **Terminal Cyberdeck TUI** | Full-screen keyboard-driven `curses` dashboard in any terminal or TTY |
| `blackarch-deck --gui` or `deck-gui` | **Graphical Desktop App** | Launches the Graphical Cyberdeck UI in a frameless desktop window |
| `blackarch-deck --web` or `deck-web` | **Web Dashboard Server** | Serves the interactive Cyberdeck UI at `http://0.0.0.0:8080` |
| `blackarch-deck --status` or `deck-status` | **CLI Telemetry Snapshot** | Prints a fast colorized summary of hardware, weather, clock, and OPSEC |
| `ba-rofi` | **Rofi / FZF Popup Menu** | Pops up a fuzzy-searchable command launcher overlay anywhere on your desktop |

---

## ⌨️ Terminal TUI Keyboard Shortcuts (`blackarch-deck`)

* `Tab` / `Left` / `Right` or `1`–`9`: Switch command categories
* `Up` / `Down` or `j` / `k`: Navigate commands in the current category
* `Enter` or `r`: Review/edit parameters and execute the selected command
* `x`: Execute command in a **full interactive terminal session** (ideal for `msfconsole`, `btop`, `sudo pacman -Syu`, `bettercap`)
* `/`: Fuzzy-search across all commands by name, tool, tag, or description
* `t`: Set Engagement Variables (`{target}`, `{lhost}`, `{lport}`)
* `w`: Change Weather City / Location
* `p`: Toggle Public IP Privacy Mask (`***.***.***.***`)
* `f`: Toggle Favorite (`★`) on the selected command
* `a`: **Add a new Custom Command** inside the UI
* `i`: Install a missing tool binary via `sudo pacman -S <package>`
* `q`: Quit

---

## 📁 Repository Structure

* `install.sh` — Post-install script for BlackArch Dual-Boot PCs
* `blackarch-deck` — Standalone Python 3 Cyberdeck UI (Terminal `curses` TUI + Web/GUI Dashboard + CLI Status)
* `configs/commands.default.json` — Default database of 56+ categorized BlackArch, OPSEC, and Dual-Boot commands
* `configs/conky-blackarch.conf` — Desktop wallpaper Conky HUD configuration
* `configs/rofi-blackarch.rasi` — BlackArch Crimson/Cyan Rofi theme
* `configs/fastfetch.jsonc` — BlackArch Fastfetch terminal configuration
* `scripts/ba-rofi-menu.sh` — Rofi & FZF quick command launcher script
