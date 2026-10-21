"""log_panel.py — Tail cyberdeck + journal logs for the TUI Log tab."""
import glob
import os
import subprocess

LOG_DIR = os.path.expanduser("~/.cyberdeck/logs")


def tail_cyberdeck_logs(lines=60):
    files = sorted(glob.glob(os.path.join(LOG_DIR, "*.log")), key=os.path.getmtime, reverse=True)
    out = []
    for path in files[:6]:
        try:
            with open(path, errors="ignore") as f:
                content = f.readlines()
            out.append(f"── {os.path.basename(path)} ──")
            out += [l.rstrip() for l in content[-15:]]
        except OSError:
            continue
    return "\n".join(out[-lines:]) if out else "(no cyberdeck logs yet — run any module)"


def tail_journal(lines=40, priority="warning"):
    p = subprocess.run(["journalctl", "--no-pager", "-n", str(lines), "-p", priority],
                       capture_output=True, text=True, timeout=10)
    return p.stdout.strip() or "(journal empty / unavailable)"


def grep_logs(term, lines=80):
    hits = []
    for path in sorted(glob.glob(os.path.join(LOG_DIR, "*.log"))):
        try:
            with open(path, errors="ignore") as f:
                hits += [f"{os.path.basename(path)}: {l.rstrip()}" for l in f if term.lower() in l.lower()]
        except OSError:
            continue
    return "\n".join(hits[-lines:]) or f"(no matches for '{term}')"
