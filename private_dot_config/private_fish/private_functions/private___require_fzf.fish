function __require_fzf -d "Check if fzf is available for interactive selection"
    set -l usage_msg $argv[1]

    if not command -v fzf >/dev/null 2>&1
        echo "Error: fzf not found. Please install it or provide arguments directly." >&2
        if test -n "$usage_msg"
            echo "Usage: $usage_msg" >&2
        end
        return 1
    end
    return 0
end
