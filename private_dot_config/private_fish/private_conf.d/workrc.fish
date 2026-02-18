# BigID Related

set -gx AWS_PROFILE admin-presales
# Let tmux set $TERM correctly (tmux-256color) -- don't override here

###################
# Alias Functions #
###################

# Download Compose, Full Image, and Scanner Image Commands
function set_token -d "Set BigID download token"
    set -g BIGID_DOWNLOADS_ACCESS_TOKEN $argv[1]
    echo "BIGID_DOWNLOADS_ACCESS_TOKEN has been set globally."
end

function set_release -d "Set BigID release version"
    set -g RELEASE $argv[1]
    echo "RELEASE has been set globally."
end

function download_bigid_file -d "Downloads BigID files"
    set -l file_type $argv[1]
    if test -z "$file_type"
        echo "Usage: download_bigid_file <file_type>"
        echo "Available file types: compose, images, images-scanner, images-labeler"
        return 1
    end

    if test -z "$BIGID_DOWNLOADS_ACCESS_TOKEN"
        __error_msg "BIGID_DOWNLOADS_ACCESS_TOKEN is not set or empty."
        return 1
    end

    if test -z "$RELEASE"
        __error_msg "RELEASE is not set or empty."
        return 1
    end

    set -l file_name "bigid-$file_type-release-$RELEASE.tar.gz"
    set -l url "https://us.downloads.bigid.com/?file=release-$RELEASE/$file_name"

    echo "Downloading $file_name..."
    curl -H "Authorization: $BIGID_DOWNLOADS_ACCESS_TOKEN" -L "$url" -o "$file_name"
end

# Registry Logins
function bidlogin -d "Login to BigID Docker registry"
    if not set -q DOCKERHUB_USERNAME; or not set -q DOCKERHUB_TOKEN
        echo "Error: DOCKERHUB_USERNAME and DOCKERHUB_TOKEN must be set as environment variables."
        return 1
    end
    docker login -u "$DOCKERHUB_USERNAME" -p "$DOCKERHUB_TOKEN"
end

function ecrlogin -d "Login to AWS ECR"
    aws --profile bigid-ci ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 656782941097.dkr.ecr.us-east-1.amazonaws.com
end

function awslogs-trace -d "Tail AWS CloudWatch logs with filter pattern"
    set -l log_group $argv[1]
    set -l pattern $argv[2]
    if test -z "$log_group" -o -z "$pattern"
        echo "Usage: awslogs-trace <log-group-name> <pattern-to-find>" >&2
        echo "Example: awslogs-trace /aws/lambda/my-function ERROR" >&2
        return 1
    end
    # The filter pattern requires quotes around the string you're searching for
    aws logs tail --follow $log_group --filter-pattern "\"$pattern\""
end

# Abbreviations
if status is-interactive
    # BigID Download
    abbr --add gcpse "download_bigid_file compose"
    abbr --add gimgse "download_bigid_file images"
    abbr --add gscanse "download_bigid_file images-scanner"
    abbr --add glabse "download_bigid_file images-labeler"

    # AWS Logs
    abbr --add awslogs-groups "aws logs describe-log-groups --query 'logGroups[*].logGroupName' --output text | tr -s '\t' '\n' | sort"
    abbr --add awslogs-tailf "aws logs tail --follow"
    abbr --add awslogs-15m "aws logs tail --since 15m"

    # Kubernetes
    abbr --add k kubectl
    abbr --add kg kubectl get
    abbr --add kd kubectl describe
    abbr --add kdel kubectl delete
    abbr --add kl kubectl logs
    abbr --add klf kubectl logs -f
    abbr --add ke kubectl exec -it
    abbr --add kpf kubectl port-forward
    abbr --add kap kubectl apply -f
    abbr --add kgp kubectl get pods
    abbr --add kgn kubectl get nodes
    abbr --add kgs kubectl get services
    abbr --add kgd kubectl get deployments
    abbr --add kgi kubectl get ingress
    abbr --add kgpvc kubectl get pvc
    abbr --add kdp kubectl describe pod
    abbr --add kdn kubectl describe node
    abbr --add kds kubectl describe service
    abbr --add kdd kubectl describe deployment

    # Kubernetes - Output formats
    abbr --add kgpw "kubectl get pods -o wide"
    abbr --add kgy  "kubectl get -o yaml"

    # Kubernetes - Additional resources
    abbr --add kgcm  "kubectl get configmaps"
    abbr --add kgsec "kubectl get secrets"
    abbr --add kgss  "kubectl get statefulsets"
    abbr --add kgns  "kubectl get namespaces"

    # Kubernetes - Rollouts
    abbr --add kro  "kubectl rollout"
    abbr --add kros "kubectl rollout status"
    abbr --add kror "kubectl rollout restart"

    # Kubernetes - Resource usage
    abbr --add ktop  "kubectl top pods"
    abbr --add ktopn "kubectl top nodes"

    # Kubernetes - Scale
    abbr --add ksc "kubectl scale"

    # Helm
    abbr --add h helm
    abbr --add hl helm list
    abbr --add hi helm install
    abbr --add hu helm upgrade
    abbr --add hun helm uninstall
    abbr --add hh helm history
    abbr --add hr helm rollback

    # Docker
    abbr --add d docker
    abbr --add dc docker-compose
    abbr --add dps docker ps
    abbr --add dpsa docker ps -a
    abbr --add di docker images
    abbr --add dex docker exec -it
    abbr --add dl docker logs
    abbr --add dlf docker logs -f
    abbr --add drm docker rm
    abbr --add drmi docker rmi
    abbr --add dprune docker system prune -af

    # Terraform
    abbr --add tf terraform
    abbr --add tsl "terraform state list"
    abbr --add tit "terraform init"
    abbr --add tout "terraform output"
    abbr --add tplan "terraform plan"
    abbr --add tfmt "terraform fmt"
    abbr --add tval "terraform validate"
    abbr --add twl terraform workspace list
    abbr --add twn terraform workspace new
    abbr --add twd terraform workspace delete
    abbr --add tss "terraform state show"
    abbr --add tget "terraform get -update"
    abbr --add tref "terraform refresh"

    # Safe apply/destroy (no auto-approve)
    abbr --add ta "terraform apply"
    abbr --add td "terraform destroy"

    # For rare cases you really need auto-approve (explicit)
    abbr --add tapprove "terraform apply -auto-approve"
    abbr --add tdapprove "terraform destroy -auto-approve"
end

function tlo -d "Lock a file (make immutable)"
    if test (count $argv) -eq 0
        echo "Usage: tlo <file>" >&2
        echo "Locks a file to prevent modifications (requires sudo)" >&2
        return 1
    end

    set -l file $argv[1]
    if not test -e "$file"
        __error_msg "File '$file' does not exist"
        return 1
    end

    sudo chflags uchg "$file"
    and __success_msg "Locked: $file"
end

function tul -d "Unlock a file (make mutable)"
    if test (count $argv) -eq 0
        echo "Usage: tul <file>" >&2
        echo "Unlocks a file to allow modifications (requires sudo)" >&2
        return 1
    end

    set -l file $argv[1]
    if not test -e "$file"
        __error_msg "File '$file' does not exist"
        return 1
    end

    sudo chflags nouchg "$file"
    and __success_msg "Unlocked: $file"
end

# Misc AWS
function elc -d "List ECS clusters"
    aws ecs list-clusters --query 'clusterArns' --output text
end

function elt -d "List ECS tasks in a cluster"
    set -l cluster $argv[1]
    if test -z "$cluster"
        echo "Usage: elt <cluster_name>"
        return 1
    end
    aws ecs list-tasks --cluster "$cluster" --output text
end

function els -d "List ECS services in a cluster"
    set -l cluster $argv[1]
    if test -z "$cluster"
        echo "Usage: els <cluster_name>"
        return 1
    end
    aws ecs list-services --cluster "$cluster" --output text
end

# AWS Quick Lookups
function aws-ec2 -d "List EC2 instances with details"
    aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]' --output table
end

function aws-s3 -d "List S3 buckets"
    aws s3 ls
end

function aws-rds -d "List RDS instances"
    aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceStatus,Endpoint.Address]' --output table
end

function aws-lambda -d "List Lambda functions"
    aws lambda list-functions --query 'Functions[*].[FunctionName,Runtime,LastModified]' --output table
end

function aws-eks -d "List EKS clusters"
    aws eks list-clusters --output table
end

# Azure Quick Lookups
function az-vm -d "List Azure VMs"
    az vm list --output table
end

function az-aks -d "List AKS clusters"
    az aks list --output table
end

function az-rg -d "List Azure resource groups"
    az group list --output table
end

# GCP Quick Lookups
function gcp-gce -d "List GCE instances"
    gcloud compute instances list --format="table(name,zone,machineType,status,networkInterfaces[0].networkIP)"
end

function gcp-gke -d "List GKE clusters"
    gcloud container clusters list --format="table(name,location,status,currentMasterVersion,currentNodeCount)"
end

function gcp-gcs -d "List GCS buckets"
    gcloud storage buckets list --format="table(name,location,storageClass,timeCreated)"
end
