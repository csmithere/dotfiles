# SSH into a GCP compute instance
function gssh -d "SSH into GCP instance"
    # Check if gcloud is installed
    if not command -v gcloud >/dev/null 2>&1
        echo "Error: gcloud command not found. Please install Google Cloud SDK." >&2
        return 1
    end

    # Check if an instance name was provided
    if test (count $argv) -lt 1
        echo "Usage: gssh <instance-name> [additional-gcloud-flags...]" >&2
        echo "Example: gssh my-instance --zone=us-central1-a" >&2
        return 1
    end

    set -l instance $argv[1]
    set -l extra_args $argv[2..-1]

    # Get the current gcloud account for username
    set -l gcp_user (gcloud config get-value account 2>/dev/null | string replace '@' '_' | string replace '.' '_')

    if test -z "$gcp_user"
        echo "Error: No gcloud account configured. Run 'gcloud auth login' first." >&2
        return 1
    end

    # SSH into the instance
    gcloud compute ssh "$gcp_user@$instance" $extra_args \
        --plain \
        --ssh-flag="-o StrictHostKeyChecking=accept-new" \
        --ssh-flag="-o UserKnownHostsFile=/dev/null"
end
