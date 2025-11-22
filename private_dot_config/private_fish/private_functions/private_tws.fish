# Switch Terraform workspace interactively or set it directly
function tws -d "Switch Terraform workspace interactively or set it directly"
    # Check if terraform is available
    __require_command terraform; or return 1

    # Check if we're in a terraform directory
    if not test -f .terraform/terraform.tfstate
        __error_msg "Not in a terraform directory (run 'terraform init' first)."
        return 1
    end

    if count $argv -gt 0
        # Direct workspace set
        set -l workspace $argv[1]
        terraform workspace select "$workspace"
    else
        # Interactive selection with fzf
        __require_fzf "tws <workspace-name>"; or return 1

        set -l workspace (terraform workspace list | sed 's/\*//g' | awk '{print $1}' | fzf --prompt="Select Terraform Workspace: ")

        if test -n "$workspace"
            terraform workspace select "$workspace"
        else
            echo "Current workspace:"
            terraform workspace show
        end
    end
end
