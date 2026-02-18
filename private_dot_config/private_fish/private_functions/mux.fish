function mux -d "Start or attach to the bigid-platform tmux session"
    set -l session bigid-platform

    if tmux has-session -t $session 2>/dev/null
        if set -q TMUX
            tmux switch-client -t $session
        else
            tmux attach-session -t $session
        end
    else
        tmuxinator start bigid-platform
    end
end
