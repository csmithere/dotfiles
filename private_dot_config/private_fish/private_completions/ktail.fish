function __fish_ktail_get_pods
    set -l namespace (kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
    if test -z "$namespace"
        set namespace default
    end
    set -l tokens (commandline -opc)
    
    for i in (seq (count $tokens))
        if test "$tokens[$i]" = "-n" -o "$tokens[$i]" = "--namespace"
            if test (count $tokens) -gt $i
                set namespace $tokens[(math $i + 1)]
            end
        end
    end

    kubectl get pods -n $namespace --no-headers -o custom-columns=:metadata.name 2>/dev/null
end

# Disable standard file completion
complete -c ktail -f

# Namespace flag completion
complete -c ktail -s n -l namespace -d "Namespace" -a "(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n')"

# Pod completion (dynamic based on namespace)
complete -c ktail -a "(__fish_ktail_get_pods)"