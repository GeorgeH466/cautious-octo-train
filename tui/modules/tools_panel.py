"""tools_panel.py — Tool registry discovery + runner for the Cyberdeck TUI."""
import os
import subprocess

CATEGORIES = ["network", "recon", "exploit", "defense", "crypto", "system", "ui", "cyberdeck"]


def script_roots():
    here = os.path.dirname(os.path.abspath(__file__))
    return [os.path.join(here, "..", "..", "scripts"),
            os.path.expanduser("~/.cyberdeck/scripts")]


def discover_tools():
    """Return {category: [(name, description, path), ...]} from disk."""
    root = next((r for r in script_roots() if os.path.isdir(r)), script_roots()[0])
    found = {}
    for cat in CATEGORIES:
        cdir = os.path.join(root, cat)
        items = []
        if os.path.isdir(cdir):
            for fn in sorted(os.listdir(cdir)):
                if fn.endswith(".sh"):
                    path = os.path.join(cdir, fn)
                    desc = _desc(path)
                    items.append((fn[:-3], desc, path))
        found[cat] = items
    return found


def _desc(path):
    try:
        with open(path, errors="ignore") as f:
            for line in f:
                if ".sh —" in line:
                    return line.split("—", 1)[1].strip()
                if not line.startswith("#"):
                    break
    except OSError:
        pass
    return ""


def run_tool(path, args=None, timeout=120):
    """Run a tool, return (rc, combined output). Logged by the tool itself too."""
    cmd = ["bash", path] + list(args or [])
    env = dict(os.environ, NO_COLOR="1", CYBERDECK_YES="0")
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout, env=env)
        return p.returncode, (p.stdout + p.stderr)
    except subprocess.TimeoutExpired as e:
        return 124, f"[timeout after {timeout}s]\n" + (e.stdout or "")
    except Exception as e:  # pragma: no cover
        return 1, f"[error launching tool: {e}]"


MISSIONS = {
    "LAN Recon Sweep": [("network", "net-discover"), ("network", "arp-spoof-detect")],
    "Web Target Profile": [("recon", "web-tech-detect"), ("recon", "header-analyze"), ("recon", "ssl-analyze")],
    "Daily Defense Check": [("defense", "system-harden"), ("defense", "log-analyzer"), ("defense", "rootkit-check")],
    "Deck Maintenance": [("system", "update-all"), ("system", "cleanup"), ("defense", "backup-manager")],
}
