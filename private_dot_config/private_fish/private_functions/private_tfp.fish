# Run terraform plan with better formatting and output
function tfp -d "Terraform plan with better formatting"
    __require_command terraform; or return 1

    # Run terraform plan and save to file
    echo "Running terraform plan..."
    terraform plan -out=tfplan.out $argv

    if test $status -eq 0
        # Convert plan to readable format
        terraform show -no-color tfplan.out > tfplan.txt

        # Display with bat if available, otherwise use cat
        if command -v bat >/dev/null 2>&1
            bat tfplan.txt --language=terraform
        else
            cat tfplan.txt
        end

        echo ""
        echo "Plan saved to: tfplan.out"
        echo "Readable plan saved to: tfplan.txt"
        echo ""
        echo "To apply: terraform apply tfplan.out"
    else
        __error_msg "Terraform plan failed"
        return 1
    end
end
