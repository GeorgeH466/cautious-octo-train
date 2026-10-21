#!/usr/bin/env bash
# hex-dump-visual.sh — Colourised visual hex dump (entropy & string highlights)
# Cyberdeck-BlackArch | MIT | Part of scripts/ui/
set -uo pipefail
_SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _L in "$_SDIR/../../lib" "$HOME/.cyberdeck/lib" "$HOME/.local/share/cyberdeck/lib"; do [[ -f "$_L/utils.sh" ]] && { LIB="$_L"; break; }; done
if [[ -n "${LIB:-}" ]]; then source "$LIB/colors.sh"; source "$LIB/ui.sh"; source "$LIB/utils.sh"; else echo "[!] cyberdeck lib not found — run ./install.sh first" >&2; exit 1; fi
usage() { cyber_banner "HEX-DUMP-VISUAL" "Colourised visual hex dump (entropy & string highlights)"; cat <<USAGE
  USAGE: hex-dump-visual.sh <file> [bytes]
  Colour dump via hexyl/xxd + entropy estimate + embedded strings preview.
USAGE
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" || "${1:-}" == "help" ]] && { usage; exit 0; }
# coreutils only
main() { cyber_banner "HEX-DUMP-VISUAL" "Colourised visual hex dump (entropy & string highlights)"; log_msg "START args: $*"

  local f="${1:-}"; [[ -f "$f" ]] || die "Usage: hex-dump-visual <file> [bytes]"
  local n="${2:-512}"; kv "File" "$f ($(stat -c%s "$f") bytes, $(file -b "$f"|head -c 60))"
  section "HEXDUMP (first $n bytes)"
  if have hexyl; then hexyl -n "$n" "$f"
  else head -c "$n" "$f" | xxd -g1 | sed -E "s/^([0-9a-f]+:)/${C_PRIMARY}\1${C_RESET}/" | sed 's/^/  /'; fi
  section "ENTROPY"; python3 - "$f" <<'PYEOF'
import math,sys,collections
d=open(sys.argv[1],'rb').read(1<<20); c=collections.Counter(d); n=len(d)
e=-sum(v/n*math.log2(v/n) for v in c.values()) if n else 0
print(f"  Shannon entropy: {e:.2f} / 8.00  ({'HIGH — encrypted/compressed' if e>7.2 else 'normal structure'})")
PYEOF
  section "STRINGS (sample)"; strings -n 6 "$f" | head -15 | sed 's/^/  /' 
  log_msg "DONE"; }
main "$@"
