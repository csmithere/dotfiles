function kns -d "Switch kubectl namespace interactively"
    __require_command kubectl; or return 1

    if test (count $argv) -gt 0
        kubectl config set-context --current --namespace=$argv[1]
        if test $status -eq 0
            __success_msg "Namespace set to:" (__highlight "$argv[1]")
        else
            __error_msg "Failed to set namespace to '$argv[1]'"
            echo "Available namespaces:" >&2
            kubectl get namespaces -o name >&2
            return 1
        end
    else
        if command -v fzf >/dev/null 2>&1
            set -l namespace (kubectl get namespaces -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | fzf --prompt="Select Namespace: ")
            if test -n "$namespace"
                kubectl config set-context --current --namespace="$namespace"
                if test $status -eq 0
                    __success_msg "Namespace set to:" (__highlight "$namespace")
                else
                    __error_msg "Failed to set namespace to '$namespace'"
                    return 1
                end
            end
        else
            kubectl get namespaces
        end
    end
end
