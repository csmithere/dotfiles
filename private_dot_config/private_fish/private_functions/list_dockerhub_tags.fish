# A fish function to list the 20 LATEST tags for a specific Docker Hub repository.
# This version uses hardcoded credentials for authentication.
function list_dockerhub_tags
    # 1. Check for dependencies
    if not command -v -q curl; echo "ERROR: 'curl' is not installed." >&2; return 1; end
    if not command -v -q jq; echo "ERROR: 'jq' is not installed." >&2; return 1; end

    # 2. Check for correct arguments
    if test (count $argv) -ne 1
        echo "Usage: (status function) <NAMESPACE/REPOSITORY>"
        echo "Example: (status function) bitnami/nginx"
        return 1
    end

    set REPO $argv[1]

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

    if test "$API_TOKEN" = "null" -o -z "$API_TOKEN"
        echo " Authentication failed. Please check the hardcoded username and PAT." >&2
        return 1
    end

    echo " Authentication successful. Fetching the 20 latest tags for '$REPO'..."
    echo "---"

    # 4. Fetch the 20 latest tags for the repository.
    # We set page_size=20 and make a single API call, removing the need for the pagination loop.
    set API_URL "https://hub.docker.com/v2/repositories/$REPO/tags/?page_size=20"
    
    curl -s -H "Authorization: JWT $API_TOKEN" "$API_URL" | jq -r '.results[].name'

    echo "---"
    echo " Done."
end
