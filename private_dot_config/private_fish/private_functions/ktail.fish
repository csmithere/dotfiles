function ktail
    argparse 'n/namespace=' 'c/container=' 'p/previous' 'l/lines=' -- $argv
    or return 1

    set -l namespace (kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
    if set -q _flag_namespace
        set namespace $_flag_namespace
    else if test -z "$namespace"
        set namespace default
    end

    set -l pod $argv[1]
    set -l search_term $argv[2]

    # Interactive Mode
    if test -z "$pod"
        if command -v fzf >/dev/null
            # Fetch pods and create a mapping for display
            set -l pod_list (kubectl get pods -n $namespace --no-headers -o custom-columns=":metadata.name" 2>/dev/null)
            
            if test -z "$pod_list"
                echo "No pods found in namespace: $namespace"
                return 1
            end

            # fzf configuration:
            # - --preview-window top:50%: Gives logs full width
            # - awk/sed logic: Displays shortened names but returns full name
            set pod (printf "%s\n" $pod_list | \
                awk '{ 
                    display=$0; 
                    gsub(/-[a-z0-9]{8,10}-[a-z0-9]{5}$/, "", display); 
                    gsub(/-[0-9]+$/, "", display); 
                    print display "  " $0 
                }' | \
                fzf --prompt="Select Pod ($namespace): " \
                    --with-nth 1 \
                    --preview-window "top:60%" \
                    --preview "echo -e '\033[1;34mLogs for {2}\033[0m\n'; kubectl logs -n $namespace --tail=50 {2}" | \
                awk '{print $2}')

            if test -z "$pod"
                return 0
            end
        else
            echo "Usage: ktail [-n namespace] <pod-name> [search-term]"
            return 1
        end
    end

    # Shorten name for the "Tailing..." message
    set -l short_name (echo $pod | sed -E 's/-[a-z0-9]{8,10}-[a-z0-9]{5}$//; s/-[0-9]+$//')
    
    set -l cmd kubectl logs -n $namespace -f $pod
    if set -q _flag_container; set cmd $cmd -c $_flag_container; end
    if set -q _flag_previous; set cmd $cmd --previous; end
    if set -q _flag_lines; set cmd $cmd --tail=$_flag_lines; end

    if test -z "$search_term"
        echo "Tailing $short_name..."
        $cmd
    else
        echo "Tailing $short_name for '$search_term'..."
        $cmd | grep -i -A 20 --line-buffered --color=always "$search_term"
    end
end