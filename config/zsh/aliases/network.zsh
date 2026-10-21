# Cyberdeck aliases — network (bare module names already work via PATH; these add shortcuts)
alias scan='net-scan'; alias discover='net-discover'; alias pscan='port-scan'
alias traffic='traffic-monitor'; alias sniff='sudo tcpdump -i any -nn'
alias conns='connection-monitor'; alias listen='nc -lvnp'
alias pubip='curl -fsS https://icanhazip.com'; alias flushdns='sudo resolvectl flush-caches 2>/dev/null; echo flushed'
alias mtrg='mtr --report'
