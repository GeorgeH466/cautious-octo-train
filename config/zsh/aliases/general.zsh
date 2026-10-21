# Cyberdeck aliases — general shell
alias ll='ls -lah --color=auto --group-directories-first'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'; alias ...='cd ../..'; alias ....='cd ../../..'
alias grep='grep --color=auto'; alias diff='diff --color=auto'
alias df='df -h'; alias du='du -h'; alias free='free -h'
alias ports='ss -tunap'; alias listening='ss -tlnp'
alias myip='curl -fsS https://icanhazip.com'; alias localip="ip -4 -o addr show scope global | awk '{print \$2, \$4}'"
alias reload='exec $SHELL'; alias zshrc='${EDITOR:-vim} ~/.zshrc'
alias deck='cd ~/.cyberdeck'; alias notes='${EDITOR:-vim} ~/.cyberdeck/notes'
alias crt='cool-retro-term'
alias weather='curl -fsS wttr.in/?format=3'
