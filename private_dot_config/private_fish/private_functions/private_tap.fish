# Terraform apply with plan review
function tap -d "Terraform apply with plan review"
    __require_command terraform; or return 1

    # Generate plan
    echo "Running terraform plan..."
    terraform plan -out=tfplan $argv

    if test $status -ne 0
        __error_msg "Plan failed"
        return 1
    end

    # Store plan file for later use
    set -g LAST_TF_PLAN tfplan

    # Show plan summary
    echo ""
    terraform show tfplan | grep -E "Plan:|No changes"
    echo ""

    # Prompt to apply
    read -P "Apply this plan? [y/N] " -n 1 confirm
    echo ""

    if test "$confirm" = "y" -o "$confirm" = "Y"
        terraform apply tfplan
        set -l apply_status $status

        # Clean up plan file after successful apply
        if test $apply_status -eq 0
            rm -f tfplan
            __success_msg "Apply completed successfully"
        else
            __error_msg "Apply failed - plan file preserved at tfplan"
            return 1
        end
    else
        echo "Plan saved to tfplan"
        echo "To apply later: terraform apply tfplan (or use 'tfa')"
    end
end
