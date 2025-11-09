# List the 20 latest tags for a specific Docker Hub repository
function list_dockerhub_tags -d "List the 20 latest DockerHub tags for a repository"
    # Check for correct arguments
    if test (count $argv) -ne 1
        echo "Usage: list_dockerhub_tags <NAMESPACE/REPOSITORY>" >&2
        echo "Example: list_dockerhub_tags bitnami/nginx" >&2
        return 1
    end

    set -l repo $argv[1]

    # Authenticate and get API token
    echo "Authenticating with DockerHub API..."
    set -l api_token (__dockerhub_auth)
    or return 1

    echo "Fetching the 20 latest tags for '$repo'..."
    echo "---"

    # Fetch the 20 latest tags for the repository
    set -l api_url "https://hub.docker.com/v2/repositories/$repo/tags/?page_size=20"

    curl -s -H "Authorization: JWT $api_token" "$api_url" | jq -r '.results[].name'

    echo "---"
    echo "Done."
end
