# Switch AWS profile interactively or set it directly
function awsp -d "Switch AWS profile interactively or set it directly"
    # Check if AWS CLI is available
    if not command -v aws >/dev/null 2>&1
        echo "Error: AWS CLI not found. Please install it first." >&2
        return 1
    end

    if count $argv -gt 0
        # Direct profile set
        set -l profile $argv[1]

        # Verify profile exists
        if not aws configure list-profiles | grep -q "^$profile\$"
            echo "Error: Profile '$profile' not found." >&2
            echo "Available profiles:" >&2
            aws configure list-profiles >&2
            return 1
        end

        set -gx AWS_PROFILE $profile

        if count $argv -gt 1
            set -gx AWS_REGION $argv[2]
            echo "✅ AWS profile set to:" (set_color green) "$AWS_PROFILE" (set_color normal) " (Region: $AWS_REGION)"
        else
            set -l region (aws configure get profile.$profile.region 2>/dev/null)
            if test -n "$region"
                set -gx AWS_REGION $region
                echo "✅ AWS profile set to:" (set_color green) "$AWS_PROFILE" (set_color normal) " (Region: $region)"
            else
                echo "✅ AWS profile set to:" (set_color green) "$AWS_PROFILE" (set_color normal)
            end
        end
    else
        # Interactive selection with fzf
        if not command -v fzf >/dev/null 2>&1
            echo "Error: fzf not found. Please install it or provide a profile name directly." >&2
            echo "Usage: awsp <profile-name> [region]" >&2
            return 1
        end

        set -l profile (aws configure list-profiles | fzf --prompt="Select AWS Profile: ")

        if test -n "$profile"
            set -gx AWS_PROFILE $profile
            set -l region (aws configure get profile.$profile.region 2>/dev/null)
            if test -n "$region"
                set -gx AWS_REGION $region
                echo "✅ AWS profile set to:" (set_color green) "$AWS_PROFILE" (set_color normal) " (Region: $region)"
            else
                echo "✅ AWS profile set to:" (set_color green) "$AWS_PROFILE" (set_color normal)
            end
        else if set -q AWS_PROFILE
            echo "Current AWS profile is:" (set_color blue) "$AWS_PROFILE" (set_color normal)
        else
            echo "No AWS profile is set."
        end
    end
end
