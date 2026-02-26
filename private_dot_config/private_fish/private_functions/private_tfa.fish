# Apply the last generated terraform plan
function tfa -d "Apply the last generated plan"
    __require_command terraform; or return 1

    # Try to find a plan file
    set -l plan_file ""

    # First check if we have a stored plan from tfp/tap
    if set -q LAST_TF_PLAN
        if test -f "$LAST_TF_PLAN"
            set plan_file $LAST_TF_PLAN
        end
    end

    # If not found, look for common plan file names
    if test -z "$plan_file"
        for file in tfplan tfplan.out
            if test -f "$file"
                set plan_file $file
                break
            end
        end
    end

    if test -z "$plan_file"
        __error_msg "No plan file found. Run 'tfp' or 'tap' first."
        return 1
    end

    echo "Applying plan from: $plan_file"
    terraform apply $plan_file

    if test $status -eq 0
        # Clean up plan file after successful apply
        rm -f $plan_file
        __success_msg "Apply completed successfully"
    else
        __error_msg "Apply failed"
        return 1
    end
end
