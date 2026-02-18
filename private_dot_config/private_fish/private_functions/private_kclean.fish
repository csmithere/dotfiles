function kclean -d "Remove unreachable contexts from kubeconfig"
    __require_command kubectl; or return 1

    echo "Checking contexts for reachability..."

    set -l contexts_to_delete
    set -l clusters_to_delete
    set -l users_to_delete

    for context in (kubectl config get-contexts -o name)
        echo -n "Testing $context... "

        # Test if cluster is reachable without switching context
        kubectl cluster-info --context $context --request-timeout=2s >/dev/null 2>&1

        if test $status -ne 0
            echo "unreachable"

            # Get associated cluster and user before deleting
            set -l cluster (kubectl config view -o jsonpath="{.contexts[?(@.name=='$context')].context.cluster}" 2>/dev/null)
            set -l user (kubectl config view -o jsonpath="{.contexts[?(@.name=='$context')].context.user}" 2>/dev/null)

            # Add to deletion lists
            set -a contexts_to_delete $context
            if test -n "$cluster"
                set -a clusters_to_delete $cluster
            end
            if test -n "$user"
                set -a users_to_delete $user
            end
        else
            echo "ok"
        end
    end

    # Delete unreachable contexts
    if test (count $contexts_to_delete) -gt 0
        echo ""
        echo "Removing unreachable contexts:"
        for context in $contexts_to_delete
            echo "  - $context"
            kubectl config delete-context $context >/dev/null 2>&1
        end

        # Delete associated clusters
        for cluster in $clusters_to_delete
            kubectl config delete-cluster $cluster >/dev/null 2>&1
        end

        # Delete associated users
        for user in $users_to_delete
            kubectl config delete-user $user >/dev/null 2>&1
        end

        __success_msg "Removed" (count $contexts_to_delete) "unreachable context(s)"
    else
        __success_msg "All contexts are reachable"
    end
end
