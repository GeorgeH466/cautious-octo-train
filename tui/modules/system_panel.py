"""system_panel.py — System vitals data provider for the Cyberdeck TUI.

Uses psutil when available, falls back to /proc parsing so the TUI still
works on a bare BlackArch install before pip deps are installed.
"""
import os
import platform
import shutil
import time

try:
    import psutil  # type: ignore
except Exception:  # pragma: no cover
    psutil = None

BOOT = time.time()


def _proc_cpu_percent(interval=0.15):
    def snap():
        with open("/proc/stat") as f:
            parts = [int(x) for x in f.readline().split()[1:]]
        return sum(parts), parts[3] + parts[4]
    t1, i1 = snap()
    time.sleep(interval)
    t2, i2 = snap()
    dt = (t2 - t1) or 1
    return round(100 * (1 - (i2 - i1) / dt), 1)


def _proc_mem():
    info = {}
    with open("/proc/meminfo") as f:
        for line in f:
            k, v = line.split(":", 1)
            info[k.strip()] = int(v.strip().split()[0]) * 1024
    total = info.get("MemTotal", 0)
    avail = info.get("MemAvailable", info.get("MemFree", 0))
    return total, total - avail


def get_system_stats() -> dict:
    """Return dict with cpu/mem/disk/network-host vitals for rendering."""
    if psutil:
        vm = psutil.virtual_memory()
        cpu = psutil.cpu_percent(interval=0.15)
        mem_used, mem_total, mem_pct = vm.used, vm.total, vm.percent
        boot = psutil.boot_time()
    else:
        cpu = _proc_cpu_percent()
        mem_total, mem_used = _proc_mem()
        mem_pct = round(100 * mem_used / mem_total, 1) if mem_total else 0
        with open("/proc/stat") as f:
            boot = next(int(l.split()[1]) for l in f if l.startswith("btime"))
    du = shutil.disk_usage("/")
    up = int(time.time() - boot)
    return {
        "hostname": platform.node(),
        "kernel": platform.release(),
        "os": _os_name(),
        "cpu_pct": cpu,
        "mem_pct": mem_pct,
        "mem_used_gb": round(mem_used / 1e9, 1),
        "mem_total_gb": round(mem_total / 1e9, 1),
        "disk_pct": round(100 * du.used / du.total, 1) if du.total else 0,
        "disk_used_gb": round(du.used / 1e9, 1),
        "disk_total_gb": round(du.total / 1e9, 1),
        "uptime": f"{up // 86400}d {(up % 86400) // 3600}h {(up % 3600) // 60}m",
        "load": os.getloadavg() if hasattr(os, "getloadavg") else (0, 0, 0),
    }


def _os_name():
    try:
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("PRETTY_NAME="):
                    return line.split("=", 1)[1].strip().strip('"')
    except OSError:
        pass
    return platform.system()


def top_processes(limit=8):
    if psutil:
        procs = sorted(psutil.process_iter(["name", "cpu_percent", "memory_percent"]),
                       key=lambda p: p.info.get("cpu_percent") or 0, reverse=True)
        return [(p.info["name"], p.info.get("cpu_percent") or 0, round(p.info.get("memory_percent") or 0, 1)) for p in procs[:limit]]
    import subprocess
    out = subprocess.run(["ps", "-eo", "comm,%cpu,%mem", "--sort=-%cpu", "--no-headers"],
                         capture_output=True, text=True).stdout.strip().splitlines()
    rows = []
    for line in out[:limit]:
        parts = line.split()
        if len(parts) >= 3:
            rows.append((parts[0], float(parts[1]), float(parts[2])))
    return rows


def bar(pct: float, width: int = 18) -> str:
    filled = int(max(0, min(100, pct)) * width / 100)
    return "▓" * filled + "░" * (width - filled)


def render_system_rich():
    """Rich renderable used by both Textual and rich-fallback modes."""
    from rich.table import Table
    s = get_system_stats()
    t = Table(title="◢ SYSTEM VITALS", border_style="cyan", expand=True, show_header=False)
    t.add_column("k", style="dim cyan", width=14)
    t.add_column("v")
    t.add_row("HOST", f"{s['hostname']} · {s['os']} · {s['kernel']}")
    t.add_row("UPTIME", s["uptime"] + f"  load {' '.join(f'{x:.2f}' for x in s['load'])}")
    t.add_row("CPU", f"[cyan]{bar(s['cpu_pct'])}[/cyan] {s['cpu_pct']}%")
    t.add_row("RAM", f"[cyan]{bar(s['mem_pct'])}[/cyan] {s['mem_pct']}%  {s['mem_used_gb']}/{s['mem_total_gb']} GB")
    t.add_row("DISK /", f"[cyan]{bar(s['disk_pct'])}[/cyan] {s['disk_pct']}%  {s['disk_used_gb']}/{s['disk_total_gb']} GB")
    procs = " · ".join(f"{n} {c:.0f}%" for n, c, _ in top_processes(3))
    t.add_row("TOP", procs or "—")
    return t
