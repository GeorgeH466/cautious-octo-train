"""recon_panel.py — Target bookkeeping + quick lookups for the TUI Recon tab."""
import json
import os
import subprocess
import time

TARGETS_FILE = os.path.expanduser("~/.cyberdeck/targets/targets.json")


def load_targets():
    try:
        with open(TARGETS_FILE) as f:
            return json.load(f)
    except Exception:
        return []


def save_target(target, note=""):
    os.makedirs(os.path.dirname(TARGETS_FILE), exist_ok=True)
    data = load_targets()
    data = [t for t in data if t.get("target") != target]
    data.append({"target": target, "note": note, "added": time.strftime("%Y-%m-%d %H:%M")})
    with open(TARGETS_FILE, "w") as f:
        json.dump(data, f, indent=2)
    return data


def quick_lookup(target):
    """Fast, safe recon one-shot: DNS + headers (no intrusive scanning)."""
    lines = [f"⌖ TARGET: {target}", "─" * 46]
    dig = subprocess.run(["dig", "+short", target], capture_output=True, text=True, timeout=10)
    lines.append("DNS A: " + (dig.stdout.strip().replace("\n", ", ") or "—"))
    url = target if target.startswith("http") else "https://" + target
    head = subprocess.run(["curl", "-fsSI", "--max-time", "8", "-L", url],
                          capture_output=True, text=True, timeout=12)
    status = (head.stdout.splitlines() or ["(no HTTP response)"])[0]
    server = next((l for l in head.stdout.splitlines() if l.lower().startswith("server:")), "Server: —")
    lines += [f"HTTP: {status}", server]
    lines.append("Deep recon: use the Tools tab → recon category (authorised targets only).")
    return "\n".join(lines)


def render_recon_rich():
    from rich.table import Table
    t = Table(title="⌖ SAVED TARGETS (~/.cyberdeck/targets)", border_style="magenta", expand=True)
    t.add_column("Target", style="cyan")
    t.add_column("Note")
    t.add_column("Added", style="dim")
    for row in load_targets() or [{"target": "(none yet)", "note": "Add via Recon tab input", "added": ""}]:
        t.add_row(row.get("target", ""), row.get("note", ""), row.get("added", ""))
    return t
