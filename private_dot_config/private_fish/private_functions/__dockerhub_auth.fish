# Private helper function to authenticate with DockerHub API
# Returns API token on success, exits with error code on failure
function __dockerhub_auth -d "Authenticate with DockerHub API and return token"
    # Check dependencies
    if not command -v curl >/dev/null 2>&1
        echo "Error: 'curl' is not installed." >&2
        return 1
    end
    if not command -v jq >/dev/null 2>&1
        echo "Error: 'jq' is not installed." >&2
        return 1
    end

    # Check credentials are set
    if not set -q DOCKERHUB_USERNAME; or not set -q DOCKERHUB_TOKEN
        echo "Error: DOCKERHUB_USERNAME and DOCKERHUB_TOKEN must be set as environment variables (e.g., via chezmoi)." >&2
        return 1
    end

    # Authenticate with DockerHub API
    set -l api_token (curl -s -H "Content-Type: application/json" \
        -X POST \
        -d "{\"username\": \"$DOCKERHUB_USERNAME\", \"password\": \"$DOCKERHUB_TOKEN\"}" \
        https://hub.docker.com/v2/users/login/ | jq -r .token)

    if test "$api_token" = "null" -o -z "$api_token"
        echo "Error: DockerHub authentication failed. Please check your credentials." >&2
        return 1
    end

    echo $api_token
end
