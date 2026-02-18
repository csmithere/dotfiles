function mux -d "Start or attach to the bigid-platform tmux session"
    set -l session bigid-platform

    if tmux has-session -t $session 2>/dev/null
        if set -q TMUX
            tmux switch-client -t $session
        else
            tmux attach-session -t $session
        end
    else
        # Pre-load 1Password secrets once before tmuxinator spawns multiple shells
        if command -v op >/dev/null 2>&1
            set -gx MONGODB_ATLAS_PUBLIC_KEY (op read "op://Private/MongoDB Atlas/publicKey" 2>/dev/null)
            set -gx MONGODB_ATLAS_PRIVATE_KEY (op read "op://Private/MongoDB Atlas/privateKey" 2>/dev/null)
        end
        tmuxinator start bigid-platform
    end
end
