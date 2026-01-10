# Run terraform plan with better formatting and output
function tfp -d "Terraform plan with better formatting"
    __require_command terraform; or return 1

    # Run terraform plan and save to file
    echo "Running terraform plan..."
    terraform plan -out=tfplan.out $argv

    if test $status -eq 0
        # Store plan file for use by other functions
        set -g LAST_TF_PLAN tfplan.out

        # Display with color
        if command -v bat >/dev/null 2>&1
            terraform show tfplan.out | bat --language=terraform --file-name="Terraform Plan"
        else
            terraform show tfplan.out
        end

        echo ""
        __success_msg "Plan saved to:" (__highlight "tfplan.out")
        echo "To apply: terraform apply tfplan.out (or use 'tfa')"
    else
        __error_msg "Terraform plan failed"
        return 1
    end
end
