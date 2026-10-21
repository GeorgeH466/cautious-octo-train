# ════════════════════════════════════════════════════════════════════════
#  CYBERDECK // .zshrc — Powerlevel10k sci-fi prompt + full module PATH
# ════════════════════════════════════════════════════════════════════════
# Instant prompt (keep at top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export EDITOR="${EDITOR:-vim}" VISUAL="${VISUAL:-vim}" PAGER="${PAGER:-less}"
export LANG="${LANG:-en_GB.UTF-8}" LC_CTYPE="${LC_CTYPE:-en_GB.UTF-8}"
export CYBERDECK_HOME="$HOME/.cyberdeck"

# ── PATH: every cyberdeck module callable by bare name ───────────────────
path=(
  "$HOME/.cyberdeck/bin"
  "$HOME/.cyberdeck/scripts/network"
  "$HOME/.cyberdeck/scripts/recon"
  "$HOME/.cyberdeck/scripts/exploit"
  "$HOME/.cyberdeck/scripts/defense"
  "$HOME/.cyberdeck/scripts/crypto"
  "$HOME/.cyberdeck/scripts/system"
  "$HOME/.cyberdeck/scripts/ui"
  "$HOME/.cyberdeck/scripts/cyberdeck"
  "$HOME/.local/bin" $path
)
typeset -U path PATH
export PATH

# ── Oh My Zsh (if present) ────────────────────────────────────────────────
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git sudo extract history-substring-search colored-man-pages command-not-found tmux)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# ── Completion & history ──────────────────────────────────────────────────
autoload -Uz compinit && compinit -C
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
HISTFILE="$HOME/.zsh_history"; HISTSIZE=50000; SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY HIST_REDUCE_BLANKS EXTENDED_HISTORY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS INTERACTIVE_COMMENTS NO_CASE_GLOB
bindkey -e
bindkey '^[[A' history-substring-search-up 2>/dev/null || bindkey '^[[A' up-line-or-search
bindkey '^[[B' history-substring-search-down 2>/dev/null || bindkey '^[[B' down-line-or-search
autoload -Uz edit-command-line; zle -N edit-command-line; bindkey '^x^e' edit-command-line

# Syntax highlighting + autosuggestions (installed by install.sh when available)
for p in /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
         "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
         /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
         "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
  [[ -r "$p" ]] && source "$p"
done
[[ -x "$(command -v fzf)" ]] && source <(fzf --zsh 2>/dev/null)
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# ── Cyberdeck alias libraries ─────────────────────────────────────────────
for a in "$HOME/.config/zsh/aliases"/*.zsh; do [[ -r "$a" ]] && source "$a"; done

# ── Prompt ────────────────────────────────────────────────────────────────
if [[ -r "$HOME/.p10k.zsh" ]]; then source "$HOME/.p10k.zsh"
elif [[ -r "$HOME/.config/zsh/.p10k.zsh" ]]; then source "$HOME/.config/zsh/.p10k.zsh"
else
  autoload -Uz promptinit && promptinit
  PROMPT='%F{cyan}◢ [%n@%m]%f %F{white}%~%f %(?.%F{green}▸%f.%F{red}✖%f) '
  RPROMPT='%F{240}%*%f'
fi

# ── MOTD (interactive shells only, once per tmux pane ok) ─────────────────
[[ -o interactive && -x "$HOME/.cyberdeck/bin/cyberdeck-motd" ]] && "$HOME/.cyberdeck/bin/cyberdeck-motd"

# API keys for recon tools (SHODAN_API_KEY etc.) — never commit this file
[[ -r "$CYBERDECK_HOME/api-keys" ]] && set -a && source "$CYBERDECK_HOME/api-keys" && set +a
