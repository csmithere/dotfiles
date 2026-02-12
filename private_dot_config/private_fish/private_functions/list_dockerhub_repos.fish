# List all repositories for a specific Docker Hub namespace with pagination support
function list_dockerhub_repos -d "List all DockerHub repositories for a namespace"
    # Check for correct arguments
    if test (count $argv) -ne 1
        echo "Usage: list_dockerhub_repos <USERNAME_OR_ORG>" >&2
        echo "Example: list_dockerhub_repos bitnami" >&2
        return 1
    end

    set -l namespace $argv[1]

    # Authenticate and get API token
    echo "Authenticating with DockerHub API..."
    set -l api_token (__dockerhub_auth)
    or return 1

    echo "Fetching repositories for '$namespace'..."
    echo "---"

    # Fetch all repositories for the namespace, handling pagination
    set -l api_url "https://hub.docker.com/v2/repositories/$namespace/?page_size=100"

    while test -n "$api_url"
        set -l response (curl -s -H "Authorization: JWT $api_token" "$api_url")

        # Print the repository names from the current page
        echo "$response" | jq -r '.results[].name'

        # Get the URL for the next page (// empty returns nothing when .next is null)
        set api_url (echo "$response" | jq -r '.next // empty')
    end

    echo "---"
    echo "Done."
end
