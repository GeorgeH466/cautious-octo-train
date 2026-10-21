#!/usr/bin/env python3
"""generate-wallpapers.py — procedurally generate cyberdeck wallpapers.

Pure-stdlib PNG writer (zlib + struct): no Pillow required, works on any
Arch/BlackArch box. Generates 1920x1080 wallpapers per theme:
    <theme>-grid.png      Perspective Tron-style grid over a radial glow
    <theme>-circuit.png   Random circuit traces + hex accents
Usage: generate-wallpapers.py [outdir] [width height]
"""
import math
import os
import random
import struct
import sys
import zlib

THEMES = {
    "ghost": ((10, 10, 10), (0, 255, 245), (0, 90, 86)),
    "matrix": ((6, 10, 6), (0, 255, 65), (0, 110, 28)),
    "amber": ((20, 14, 4), (255, 176, 0), (120, 74, 0)),
    "blood": ((12, 2, 4), (255, 0, 64), (110, 0, 28)),
}


def write_png(path, w, h, pixels):
    """pixels: list of rows, each a bytearray of RGB triplets."""
    raw = b"".join(b"\x00" + bytes(row) for row in pixels)
    comp = zlib.compress(raw, 6)

    def chunk(typ, data):
        c = struct.pack(">I", len(data)) + typ + data
        return c + struct.pack(">I", zlib.crc32(typ + data) & 0xFFFFFFFF)

    png = (b"\x89PNG\r\n\x1a\n"
           + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
           + chunk(b"IDAT", comp)
           + chunk(b"IEND", b""))
    with open(path, "wb") as f:
        f.write(png)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def grid_wallpaper(w, h, bg, prim, dark):
    cx, cy = w / 2, h * 0.42
    horizon = int(h * 0.62)
    rows = []
    for y in range(h):
        row = bytearray(w * 3)
        for x in range(0, w, 2):  # render 2px cells, duplicate — keeps it fast
            # radial glow behind centre
            d = math.hypot(x - cx, (y - cy) * 1.6) / (w * 0.55)
            glow = max(0.0, 1.0 - d) ** 2 * 0.5
            col = lerp(bg, dark, glow)
            # subtle vertical gradient
            col = lerp(col, (0, 0, 0), (y / h) * 0.35)
            # grid floor (perspective): horizontal lines bunch near horizon
            if y > horizon:
                t = (y - horizon) / max(1, h - horizon)
                z = 1.0 / max(0.04, t)
                if abs((z * 3) % 1) < 0.10:
                    col = lerp(col, prim, 0.25 + 0.6 * t)
                vx = (x - cx) / max(1.0, (y - horizon)) * 120
                if abs(vx % 1) < 0.035:
                    col = lerp(col, prim, 0.20 + 0.55 * t)
            # fine engineering grid above horizon
            elif (x % 96 == 0 or y % 96 == 0):
                col = lerp(col, dark, 0.5)
            # horizon beam
            if abs(y - horizon) <= 1:
                col = lerp(col, prim, 0.85)
            # vignette
            v = 1 - 0.45 * ((x - cx) / cx) ** 2 - 0.3 * ((y - h / 2) / (h / 2)) ** 2
            col = tuple(max(0, min(255, int(c * max(0.35, v)))) for c in col)
            for dx in (0, 1):
                i = (x + dx) * 3
                row[i], row[i + 1], row[i + 2] = col
        rows.append(row)
    return rows


def circuit_wallpaper(w, h, bg, prim, dark, seed=1337):
    random.seed(seed)
    # start from dim gradient
    rows = []
    for y in range(h):
        col = lerp(bg, (0, 0, 0), y / h * 0.4)
        rows.append(bytearray(col * w))

    def put(x, y, col, thick=2):
        for yy in range(max(0, y), min(h, y + thick)):
            for xx in range(max(0, x), min(w, x + thick)):
                i = xx * 3
                rows[yy][i], rows[yy][i + 1], rows[yy][i + 2] = col

    def line(x0, y0, x1, y1, col, thick=2):
        steps = max(abs(x1 - x0), abs(y1 - y0), 1)
        for s in range(steps + 1):
            put(int(x0 + (x1 - x0) * s / steps), int(y0 + (y1 - y0) * s / steps), col, thick)

    # random Manhattan traces with node dots
    for _ in range(90):
        x, y = random.randrange(w), random.randrange(h)
        col = random.choice([dark, lerp(dark, prim, 0.4), lerp(dark, prim, 0.75)])
        for _ in range(random.randint(2, 6)):
            if random.random() < 0.5:
                nx = max(0, min(w - 1, x + random.randint(-260, 260)))
                line(x, y, nx, y, col)
                x = nx
            else:
                ny = max(0, min(h - 1, y + random.randint(-170, 170)))
                line(x, y, x, ny, col)
                y = ny
            if random.random() < 0.25:  # 45° jog
                d = random.randint(20, 80) * random.choice([-1, 1])
                nx, ny = max(0, min(w - 1, x + d)), max(0, min(h - 1, y + d))
                line(x, y, nx, ny, col)
                x, y = nx, ny
        for r in range(6):  # node pad
            put(x - r // 2, y - r // 2, prim if r < 3 else dark, 2)
    # sprinkle "stars" (data motes)
    for _ in range(350):
        put(random.randrange(w), random.randrange(h), lerp(bg, prim, random.random() * 0.8), 2)
    return rows


def main():
    outdir = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.abspath(__file__))
    w = int(sys.argv[2]) if len(sys.argv) > 2 else 1920
    h = int(sys.argv[3]) if len(sys.argv) > 3 else 1080
    os.makedirs(outdir, exist_ok=True)
    for name, (bg, prim, dark) in THEMES.items():
        p = os.path.join(outdir, f"{name}-grid.png")
        write_png(p, w, h, grid_wallpaper(w, h, bg, prim, dark))
        print(f"  wrote {p}")
        p = os.path.join(outdir, f"{name}-circuit.png")
        write_png(p, w, h, circuit_wallpaper(w, h, bg, prim, dark, seed=hash(name) & 0xFFFF))
        print(f"  wrote {p}")
    print("Wallpapers generated.")


if __name__ == "__main__":
    main()
