# Clean up old terraform plan files
function tfclean -d "Clean up old terraform plan files"
    set -l plan_files (ls tfplan* 2>/dev/null)

    if test (count $plan_files) -eq 0
        echo "No plan files to clean"
        return
    end

    echo "Found "(count $plan_files)" plan file(s):"
    for file in $plan_files
        set -l size (ls -lh $file | awk '{print $5}')
        set -l date (ls -l $file | awk '{print $6, $7, $8}')
        echo "  - $file ($size, $date)"
    end

    echo ""
    read -P "Delete these files? [y/N] " -n 1 confirm
    echo ""

    if test "$confirm" = "y" -o "$confirm" = "Y"
        rm -f $plan_files
        __success_msg "Cleaned up "(count $plan_files)" plan file(s)"

        # Clear the stored plan variable
        set -e LAST_TF_PLAN
    else
        echo "No files deleted"
    end
end
