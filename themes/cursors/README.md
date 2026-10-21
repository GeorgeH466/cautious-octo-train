# Cursors

The deck uses **Capitaine Cursors** (dark) via `capitaine-cursors` (AUR) with
fallback to `xcursor-vanilla-dmz`/Adwaita — set in `config/gtk/settings.ini`
(`gtk-cursor-theme-name=capitaine-cursors`). To hand-roll a neon cursor set:

```bash
# xcursorgen takes PNG frames + a .in manifest, e.g.:
xcursorgen default.in ~/.local/share/icons/cyberdeck-cursors/cursors/default
```

Then set `gtk-cursor-theme-name=cyberdeck-cursors` and re-login.
