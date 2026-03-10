if status is-interactive; and not set -q TMUX; and set -q SSH_TTY
    exec tmux
end
