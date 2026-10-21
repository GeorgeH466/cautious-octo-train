#!/usr/bin/env bash
# cheatsheet.sh — Interactive cheatsheet — commands for every tool category
# Cyberdeck-BlackArch | MIT | Part of scripts/cyberdeck/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "CHEATSHEET" "Interactive cheatsheet — commands for every tool category"; cat <<USAGE
  USAGE: cheatsheet.sh [nmap|wifi|tmux|i3|gpg|hash|web|linux]
  No args: pick from menu. Prints copy-paste-ready command cards.
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "CHEATSHEET" "Interactive cheatsheet — commands for every tool category"; log_msg "START args: $*"

  local topic="${1:-}"
  if [[ -z "$topic" ]]; then printf '  Topics: nmap wifi tmux i3 gpg hash web linux\n  Topic: '; read -r topic </dev/tty; fi
  case "$topic" in
    nmap) cat <<'CS'
  ── NMAP ────────────────────────────────────────────────────────────────
  nmap -sn 192.168.1.0/24            host discovery (ping sweep)
  nmap -sV -sC -O target             versions + scripts + OS
  nmap -p- -T4 target                all 65535 ports
  nmap -sU --top-ports 50 target     UDP scan
  nmap --script vuln target          vulnerability scripts
  nmap -oA out target                all output formats
CS
    ;;
    wifi) cat <<'CS'
  ── WI-FI AUDITING (own networks only) ───────────────────────────────────
  wifi-monitor start wlan0           monitor mode on
  sudo airodump-ng wlan0mon          survey APs/clients
  sudo airodump-ng -c 6 --bssid AA:.. -w cap wlan0mon   target capture
  aircrack-ng cap-01.cap -w rockyou.txt                 crack WPA handshake
  wifi-monitor stop                  restore managed mode
CS
    ;;
    tmux) cat <<'CS'
  ── TMUX (prefix = Ctrl-a on this deck) ─────────────────────────────────
  prefix |  /  prefix -              split vertical / horizontal
  prefix h j k l                     move between panes (vim keys)
  prefix c / n / p                   new / next / prev window
  prefix d                           detach   ·   tmux attach  re-attach
  prefix [                           copy mode (v select, y yank)
  prefix r                           reload cyberdeck tmux config
CS
    ;;
    i3) cat <<'CS'
  ── I3 KEYBINDINGS ───────────────────────────────────────────────────────
  Super+Enter terminal · Super+d launcher · Super+Shift+d script launcher
  Super+F1..F4 dashboards · Super+n LAN scan · Super+m cava · Super+b bar
  Super+Shift+l lock · Super+Shift+s screenshot · Super+1..0 workspaces
  Super+h/j/k/l focus · Super+Shift+h/j/k/l move · Super+f fullscreen
  Full list: docs/KEYBINDINGS.md
CS
    ;;
    gpg) cat <<'CS'
  ── GPG / AGE ────────────────────────────────────────────────────────────
  encrypt-file file                  passphrase-encrypt (age/gpg)
  gpg -e -r KEY file · gpg -d file.gpg · gpg --list-secret-keys
  age -r age1... -o out.age in · age -d -i key.txt out.age
  key-manager list                   all keys at a glance
CS
    ;;
    hash) cat <<'CS'
  ── HASHING & CRACKING ───────────────────────────────────────────────────
  hash-file file                     md5/sha1/sha256/sha512/b2
  hash-crack hashes.txt wordlist     hashcat wrapper (auto mode)
  hashcat -m 1000 ntlm.txt rockyou   NTLM   ·  -m 22000 WPA · -m 1800 sha512crypt
  john --wordlist=rockyou hashes     John the Ripper
CS
    ;;
    web) cat <<'CS'
  ── WEB TESTING ──────────────────────────────────────────────────────────
  web-tech-detect URL · header-analyze URL · ssl-analyze host
  gobuster dir -u URL -w common.txt  content discovery
  ffuf -u URL/FUZZ -w list.txt       fuzzing
  nuclei -u URL                      template vuln scan
  sqli-test 'URL?id=1' · xss-scan 'URL?q=1'
CS
    ;;
    linux) cat <<'CS'
  ── LINUX / POST-EXPLOIT AWARENESS ───────────────────────────────────────
  id; whoami; uname -a; cat /etc/os-release   situational awareness
  ss -tunap · ps auxf · ip a · env            what's running/connected
  find / -perm -4000 2>/dev/null              SUID binaries (audit!)
  sudo -l · crontab -l · ls -la ~/.ssh        privilege surface
  journalctl -f · dmesg -w                    live logs
CS
    ;;
    *) die "Unknown topic '$topic' (nmap|wifi|tmux|i3|gpg|hash|web|linux)" ;;
  esac
  log_msg "DONE"; }
main "$@"
