# A fish function to list all repositories for a specific Docker Hub namespace.
# This version uses hardcoded credentials for authentication.
function list_dockerhub_repos
    # 1. Check for dependencies
    if not command -v -q curl; echo "ERROR: 'curl' is not installed." >&2; return 1; end
    if not command -v -q jq; echo "ERROR: 'jq' is not installed." >&2; return 1; end

    # 2. Check for correct arguments
    if test (count $argv) -ne 1
        echo "Usage: (status function) <USERNAME_OR_ORG>"
        echo "Example: (status function) bitnami"
        return 1
    end

    set NAMESPACE $argv[1]

    if not set -q DOCKERHUB_USERNAME; or not set -q DOCKERHUB_TOKEN
        echo "Error: DOCKERHUB_USERNAME and DOCKERHUB_TOKEN must be set as environment variables (e.g., via chezmoi)."
        return 1
    end

    set -l UNAME "$DOCKERHUB_USERNAME"
    set -l TOKEN_PASS "$DOCKERHUB_TOKEN"


    # 3. Get API Token
    echo " Authenticating with Docker Hub API using hardcoded credentials..."
    set API_TOKEN (curl -s -H "Content-Type: application/json" \
        -X POST \
        -d "{\"username\": \"$UNAME\", \"password\": \"$TOKEN_PASS\"}" \
        https://hub.docker.com/v2/users/login/ | jq -r .token)

    if test "$API_TOKEN" = "null" -o -z "$API_TOKEN" # 
        echo " Authentication failed. Please check the hardcoded username and PAT." >&2 # [cite: 7]
        return 1
    end

    echo " Authentication successful. Fetching all repositories for '$NAMESPACE'..."
    echo "---"

    # 4. Fetch all repositories for the namespace, handling pagination.
    set API_URL "https://hub.docker.com/v2/repositories/$NAMESPACE/?page_size=100"
    
    while test -n "$API_URL"
        set RESPONSE (curl -s -H "Authorization: JWT $API_TOKEN" "$API_URL")
        
        # Print the repository names from the current page
        echo "$RESPONSE" | jq -r '.results[].name'

        # Get the URL for the next page
        set API_URL (echo "$RESPONSE" | jq -r '.next')
    end

    echo "---"
    echo " Done."
end
