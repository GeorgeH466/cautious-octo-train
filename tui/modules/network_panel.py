"""network_panel.py — Network status data provider for the Cyberdeck TUI."""
import subprocess


def _run(cmd):
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=6).stdout.strip()
    except Exception:
        return ""


def get_network_stats() -> dict:
    route = _run(["ip", "route", "show", "default"]).splitlines()
    iface = gw = ""
    if route:
        parts = route[0].split()
        gw = parts[2] if len(parts) > 2 else ""
        iface = parts[4] if len(parts) > 4 else ""
    local_ip = ""
    addr = _run(["ip", "-4", "-o", "addr", "show", "scope", "global"]).splitlines()
    if addr:
        local_ip = addr[0].split()[3]
    pub = _run(["curl", "-fsS", "--max-time", "4", "https://icanhazip.com"]) or "unknown"
    established = _run(["ss", "-tun", "state", "established"]).splitlines()
    listening = _run(["ss", "-tlnH"]).splitlines()
    ports = sorted({l.split()[3].rsplit(":", 1)[-1] for l in listening if len(l.split()) > 3})
    tor = "9050" in _run(["ss", "-tln"])
    ssid = ""
    iw = _run(["iw", "dev", iface, "info"]) if iface else ""
    for line in iw.splitlines():
        if "ssid" in line:
            ssid = line.strip().removeprefix("ssid ").strip()
    return {
        "iface": iface or "—", "gateway": gw or "—", "local_ip": local_ip or "—",
        "public_ip": pub, "established": max(0, len(established) - 1),
        "listening_ports": ", ".join(ports[:14]) or "—",
        "tor": "[●] online" if tor else "[○] offline",
        "ssid": ssid or "(wired / n/a)",
    }


def recent_connections(limit=10):
    out = _run(["ss", "-tunp", "state", "established"]).splitlines()[1:]
    rows = []
    for line in out[:limit]:
        p = line.split()
        if len(p) >= 5:
            rows.append((p[3], p[4], p[0]))
    return rows


def render_network_rich():
    from rich.table import Table
    n = get_network_stats()
    t = Table(title="◈ NETWORK STATUS", border_style="cyan", expand=True, show_header=False)
    t.add_column("k", style="dim cyan", width=14)
    t.add_column("v")
    t.add_row("INTERFACE", f"{n['iface']}  ·  SSID {n['ssid']}")
    t.add_row("LOCAL / GW", f"{n['local_ip']}  ▸  {n['gateway']}")
    t.add_row("PUBLIC IP", n["public_ip"])
    t.add_row("TOR", n["tor"])
    t.add_row("CONNECTIONS", f"{n['established']} established")
    t.add_row("LISTENING", n["listening_ports"])
    for loc, rem, proto in recent_connections(5):
        t.add_row("▸ " + proto, f"{loc} → {rem}")
    return t
