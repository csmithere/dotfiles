# Switch AWS profile interactively or set it directly
function awsp
    if count $argv -gt 0
        set -gx AWS_PROFILE $argv[1]
        if count $argv -gt 1
            set -gx AWS_REGION $argv[2]
            echo "✅ AWS profile set to:" (set_color green) "$AWS_PROFILE" (set_color normal) " (Region: $AWS_REGION)"
        else
            set -l region (aws configure get profile.$argv[1].region)
            if test -n "$region"
                set -gx AWS_REGION $region
                echo "✅ AWS profile set to:" (set_color green) "$AWS_PROFILE" (set_color normal) " (Region: $region)"
            else
                echo "✅ AWS profile set to:" (set_color green) "$AWS_PROFILE"
            end
        end
    else
        set -l profile (aws configure list-profiles | fzf)
        if test -n "$profile"
            set -gx AWS_PROFILE $profile
            set -l region (aws configure get profile.$profile.region)
            if test -n "$region"
                set -gx AWS_REGION $region
                echo "✅ AWS profile set to:" (set_color green) "$AWS_PROFILE" (set_color normal) " (Region: $region)"
            else
                echo "✅ AWS profile set to:" (set_color green) "$AWS_PROFILE"
            end
        else if set -q AWS_PROFILE
            echo "Current AWS profile is:" (set_color blue) "$AWS_PROFILE"
        else
            echo "No AWS profile is set."
        end
    end
end