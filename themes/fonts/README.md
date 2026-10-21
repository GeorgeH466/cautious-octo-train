# Fonts

`install.sh` installs these via pacman (BlackArch/Arch) and refreshes the font cache:

- `ttf-jetbrains-mono-nerd` — primary deck font (icons + ligature-free HUD clarity)
- `ttf-firacode-nerd` — alternative with ligatures
- `ttf-hack-nerd` — alternative

Fallback (no pacman package): install.sh downloads JetBrainsMono Nerd Font
from the official Nerd Fonts GitHub release into `~/.local/share/fonts/`.
Bundling font binaries in-git is avoided: Nerd Fonts releases are large and
frequently updated; the installer always fetches a current, verified build.
