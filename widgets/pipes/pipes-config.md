# Terminal screensavers — Cyberdeck

Install provides `pipes.sh` (via package `pipes.sh` in BlackArch/AUR as `pipes-sh`)
plus `cbonsai` and the built-in `matrix-rain`.

| Command | Effect |
|---|---|
| `pipes.sh -t 3 -f 60` | Classic plumbing, mirrored-pipe glyphs |
| `pipes.sh -t 0 -R` | Random-direction pipes |
| `cbonsai -l -i` | Growing bonsai (live, infinite) |
| `matrix-rain` | Cyberdeck digital rain (cmatrix/unimatrix/native) |
| `matrix-rain --color cyan` | Ghost-cyan rain |

XScreensaver-style idle hook (optional, add to i3 config):

```
exec --no-startup-id xidlehook --timer 600 'lock-screen' ''
```

The deck's `xss-lock` line in `config/i3/config` already locks after 10 min idle.
