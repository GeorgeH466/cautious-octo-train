#!/usr/bin/env python3
"""generate-sounds.py — synthesize the cyberdeck UI sound pack (stdlib only).

boot.wav         rising init sweep + confirm chord
alert.wav        two-tone warning klaxon (short)
notification.wav soft sci-fi blip
keystroke.wav    tiny mechanical click (for optional typing feedback)
Usage: generate-sounds.py [outdir]
"""
import math
import os
import struct
import sys
import wave

SR = 44100


def save(name, samples):
    path = os.path.join(sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.abspath(__file__)), name)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with wave.open(path, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SR)
        wf.writeframes(b"".join(struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in samples))
    print(f"  wrote {path}")


def tone(freq, dur, vol=0.5, kind="sine", slide_to=None):
    n = int(SR * dur)
    out = []
    for i in range(n):
        t = i / SR
        f = freq if slide_to is None else freq + (slide_to - freq) * (i / n)
        ph = 2 * math.pi * f * t
        v = math.sin(ph) if kind == "sine" else (0.6 * math.sin(ph) + 0.3 * math.sin(2 * ph) + 0.1 * math.sin(3 * ph))
        env = min(1.0, i / (SR * 0.01)) * (1 - (i / n) ** 2 * 0.6)
        out.append(v * vol * env)
    return out


def mix(*tracks):
    n = max(len(t) for t in tracks)
    return [sum(t[i] if i < len(t) else 0 for t in tracks) for i in range(n)]


def main():
    save("boot.wav", mix(tone(120, 1.1, 0.35, slide_to=880),
                       [0.0] * int(SR * 0.55) + mix(tone(880, 0.5, 0.25), tone(1318, 0.5, 0.18), tone(1760, 0.5, 0.12))))
    alert = []
    for _ in range(3):
        alert += tone(740, 0.16, 0.5, kind="tri") + tone(523, 0.16, 0.5, kind="tri")
    save("alert.wav", alert)
    save("notification.wav", mix(tone(1244, 0.22, 0.35), [0.0] * int(SR * 0.08) + tone(1864, 0.3, 0.22)))
    click = [math.sin(2 * math.pi * 2400 * i / SR) * 0.4 * (1 - i / 900) + (0.15 if i < 40 else 0) for i in range(900)]
    save("keystroke.wav", click)
    print("Sound pack generated.")


if __name__ == "__main__":
    main()
