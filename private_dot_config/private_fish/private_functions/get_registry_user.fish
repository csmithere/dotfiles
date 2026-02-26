function get_registry_user -d "Get DockerHub registry username (lazy-loaded from 1Password)"
    if not set -q __BIGID_REGISTRY_USER_CACHED
        set -gx __BIGID_REGISTRY_USER_CACHED (op read "op://BigID/DockerHub BigID DevOps/username")
    end
    echo $__BIGID_REGISTRY_USER_CACHED
end
