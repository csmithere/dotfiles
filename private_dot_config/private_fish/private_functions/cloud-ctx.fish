function cloud-ctx -d "Show current cloud contexts"
    echo "  Cloud Contexts:"
    echo ""
    if set -q AWS_PROFILE
        echo "  AWS Profile: $AWS_PROFILE"
        if set -q AWS_REGION
            echo "  AWS Region:  $AWS_REGION"
        end
    end
    if command -v gcloud >/dev/null 2>&1
        set -l gcp_project (gcloud config get-value project 2>/dev/null)
        if test -n "$gcp_project"
            echo "  GCP Project: $gcp_project"
        end
    end
    if command -v az >/dev/null 2>&1
        set -l az_sub (az account show --query name -o tsv 2>/dev/null)
        if test -n "$az_sub"
            echo "  Azure Sub:   $az_sub"
        end
    end
    if command -v kubectl >/dev/null 2>&1
        set -l k8s_ctx (kubectl config current-context 2>/dev/null)
        set -l k8s_ns (kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
        if test -n "$k8s_ctx"
            echo "  K8s Context: $k8s_ctx"
            if test -n "$k8s_ns"
                echo "  K8s NS:      $k8s_ns"
            end
        end
    end
end
