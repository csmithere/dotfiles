function get_registry_password -d "Get DockerHub registry password (lazy-loaded from 1Password)"
    if not set -q __BIGID_REGISTRY_PASSWORD_CACHED
        set -gx __BIGID_REGISTRY_PASSWORD_CACHED (op read "op://BigID/DockerHub BigID DevOps/password")
    end
    echo $__BIGID_REGISTRY_PASSWORD_CACHED
end
