# Completions for gssh function
complete -c gssh -f -d "SSH into GCP instance"

# Complete with GCP instance names if gcloud is available
if command -v gcloud >/dev/null 2>&1
    complete -c gssh -f -a "(gcloud compute instances list --format='value(name)' 2>/dev/null)"
end
