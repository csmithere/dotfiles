# Switch Azure subscription interactively or set it directly
function azsp -d "Switch Azure subscription interactively or set it directly"
    # Check if Azure CLI is available
    __require_command az "Azure CLI"; or return 1

    if count $argv -gt 0
        # Direct subscription set
        set -l subscription $argv[1]

        az account set --subscription "$subscription" 2>/dev/null
        if test $status -eq 0
            set -l sub_name (az account show --query name -o tsv)
            __success_msg "Azure subscription set to:" (__highlight "$sub_name")
        else
            __error_msg "Subscription '$subscription' not found."
            echo "Available subscriptions:" >&2
            az account list --query '[].name' -o tsv >&2
            return 1
        end
    else
        # Interactive selection with fzf
        __require_fzf "azsp <subscription-name-or-id>"; or return 1

        set -l selection (az account list --query '[].{name:name, id:id}' -o tsv | fzf --prompt="Select Azure Subscription: ")

        if test -n "$selection"
            set -l sub_id (echo "$selection" | awk '{print $NF}')
            az account set --subscription "$sub_id"
            set -l sub_name (az account show --query name -o tsv)
            __success_msg "Azure subscription set to:" (__highlight "$sub_name")
        else if az account show >/dev/null 2>&1
            set -l current_sub (az account show --query name -o tsv)
            echo "Current Azure subscription is:" (set_color blue) "$current_sub" (set_color normal)
        else
            echo "No Azure subscription is set."
        end
    end
end
