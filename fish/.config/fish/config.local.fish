if status is-interactive; and not set -q TMUX; and set -q SSH_TTY
    tmux attach -t main 2>/dev/null; or exec tmux new -s main
end
