# Start an interactive shell in a Kubernetes pod
function kshell -d "Start shell in a Kubernetes pod"
    __require_command kubectl; or return 1

    set -l pod ""
    set -l container ""

    if test (count $argv) -lt 1
        # Interactive pod selection with fzf
        if command -v fzf >/dev/null 2>&1
            set pod (kubectl get pods --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select Pod: ")
            if test -z "$pod"
                return 1
            end
        else
            __error_msg "No pod specified and fzf not found."
            echo "Usage: kshell <pod-name> [container-name]" >&2
            return 1
        end
    else
        set pod $argv[1]
        if test (count $argv) -ge 2
            set container $argv[2]
        end
    end

    # Build the exec command
    set -l exec_cmd kubectl exec -it $pod

    # Add container flag if specified
    if test -n "$container"
        set exec_cmd $exec_cmd -c $container
    end

    # Try bash first, fall back to sh
    echo "Connecting to pod: $pod..."
    $exec_cmd -- bash 2>/dev/null
    or $exec_cmd -- sh
end
