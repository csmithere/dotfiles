function kctx -d "Switch kubectl context interactively"
    __require_command kubectl; or return 1

    if test (count $argv) -gt 0
        kubectl config use-context $argv[1]
        if test $status -eq 0
            __success_msg "Context switched to:" (__highlight "$argv[1]")
        else
            __error_msg "Failed to switch to context '$argv[1]'"
            echo "Available contexts:" >&2
            kubectl config get-contexts -o name >&2
            return 1
        end
    else
        if command -v fzf >/dev/null 2>&1
            set -l context (kubectl config get-contexts -o name | fzf --prompt="Select K8s Context: ")
            if test -n "$context"
                kubectl config use-context "$context"
                if test $status -eq 0
                    __success_msg "Context switched to:" (__highlight "$context")
                else
                    __error_msg "Failed to switch to context '$context'"
                    return 1
                end
            end
        else
            kubectl config get-contexts
        end
    end
end
