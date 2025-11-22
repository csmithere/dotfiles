# Switch GCP project interactively or set it directly
function gcpp -d "Switch GCP project interactively or set it directly"
    # Check if gcloud is available
    __require_command gcloud "Google Cloud SDK"; or return 1

    if count $argv -gt 0
        # Direct project set
        set -l project $argv[1]

        gcloud config set project "$project" 2>/dev/null
        if test $status -eq 0
            __success_msg "GCP project set to:" (__highlight "$project")
        else
            __error_msg "Project '$project' not found or not accessible."
            echo "Available projects:" >&2
            gcloud projects list --format="value(projectId)" >&2
            return 1
        end
    else
        # Interactive selection with fzf
        __require_fzf "gcpp <project-id>"; or return 1

        set -l project (gcloud projects list --format="table(projectId, name)" | tail -n +2 | fzf --prompt="Select GCP Project: " | awk '{print $1}')

        if test -n "$project"
            gcloud config set project "$project"
            __success_msg "GCP project set to:" (__highlight "$project")
        else
            set -l current_project (gcloud config get-value project 2>/dev/null)
            if test -n "$current_project"
                echo "Current GCP project is:" (set_color blue) "$current_project" (set_color normal)
            else
                echo "No GCP project is set."
            end
        end
    end
end
