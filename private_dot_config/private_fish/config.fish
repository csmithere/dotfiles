set PATH $HOME/.local/bin $PATH
if status is-interactive
    # Commands to run in interactive sessions can go here

    # thefuck - Only load in interactive shells to improve startup time
    if command -v thefuck >/dev/null 2>&1
        thefuck --alias | source
    end

    # Command abbreviations - These expand visually when you type them
    # Use abbr instead of alias for better history and inline editing
    if command -v lsd >/dev/null 2>&1
        abbr --add ls lsd
    end
    if command -v nvim >/dev/null 2>&1
        abbr --add vi nvim
        abbr --add vim nvim
    end
    if command -v bat >/dev/null 2>&1
        abbr --add cat bat
    end
    if command -v rg >/dev/null 2>&1
        abbr --add grep rg
    end
end

# Set EDITOR based on what's available
if command -v nvim >/dev/null 2>&1
    set -gx EDITOR nvim
else if command -v vim >/dev/null 2>&1
    set -gx EDITOR vim
else
    set -gx EDITOR vi
end


# AWS cli completion - Use command -v instead of which for better performance
if command -v aws_completer >/dev/null 2>&1
    complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
end

# 1Password SSH Agent
set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# Pre-Commit
set -x PRE_COMMIT_COLOR never

# Kubectl Completion
if command -v kubectl >/dev/null 2>&1
    kubectl completion fish | source
end

# Kubernetes context and namespace switchers
function kctx -d "Switch kubectl context interactively"
    __require_command kubectl; or return 1

    if count $argv -gt 0
        kubectl config use-context $argv[1]
        if test $status -eq 0
            __success_msg "Context switched to:" (__highlight "$argv[1]")
        else
            __error_msg "Failed to switch to context '$argv[1]'"
            echo "Available contexts:" >&2
            kubectl config get-contexts -o name >&2
            return 1
        end
    else
        if command -v fzf >/dev/null 2>&1
            set -l context (kubectl config get-contexts -o name | fzf --prompt="Select K8s Context: ")
            if test -n "$context"
                kubectl config use-context "$context"
                if test $status -eq 0
                    __success_msg "Context switched to:" (__highlight "$context")
                else
                    __error_msg "Failed to switch to context '$context'"
                    return 1
                end
            end
        else
            kubectl config get-contexts
        end
    end
end

function kns -d "Switch kubectl namespace interactively"
    __require_command kubectl; or return 1

    if count $argv -gt 0
        kubectl config set-context --current --namespace=$argv[1]
        if test $status -eq 0
            __success_msg "Namespace set to:" (__highlight "$argv[1]")
        else
            __error_msg "Failed to set namespace to '$argv[1]'"
            echo "Available namespaces:" >&2
            kubectl get namespaces -o name >&2
            return 1
        end
    else
        if command -v fzf >/dev/null 2>&1
            set -l namespace (kubectl get namespaces -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | fzf --prompt="Select Namespace: ")
            if test -n "$namespace"
                kubectl config set-context --current --namespace="$namespace"
                if test $status -eq 0
                    __success_msg "Namespace set to:" (__highlight "$namespace")
                else
                    __error_msg "Failed to set namespace to '$namespace'"
                    return 1
                end
            end
        else
            kubectl get namespaces
        end
    end
end

# Multi-cloud context display
function cloud-ctx -d "Show current cloud contexts"
    echo "☁️  Cloud Contexts:"
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

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/csmith/.lmstudio/bin
# End of LM Studio CLI section


# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
set --export --prepend PATH "/Users/csmith/.rd/bin"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
