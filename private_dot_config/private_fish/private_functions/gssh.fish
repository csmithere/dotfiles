# SSH into a GCP compute instance
function gssh -d "SSH into GCP instance"
    # Check if gcloud is installed
    __require_command gcloud "Google Cloud SDK"; or return 1

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
        __error_msg "No gcloud account configured. Run 'gcloud auth login' first."
        return 1
    end

    # SSH into the instance
    gcloud compute ssh "$gcp_user@$instance" $extra_args \
        --plain \
        --ssh-flag="-o StrictHostKeyChecking=accept-new" \
        --ssh-flag="-o UserKnownHostsFile=/dev/null"
end
