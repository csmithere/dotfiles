# Switch AWS profile interactively or set it directly
function awsp -d "Switch AWS profile interactively or set it directly"
    # Check if AWS CLI is available
    __require_command aws "AWS CLI"; or return 1

    if count $argv -gt 0
        # Direct profile set
        set -l profile $argv[1]

        # Verify profile exists
        if not aws configure list-profiles | grep -q "^$profile\$"
            __error_msg "Profile '$profile' not found."
            echo "Available profiles:" >&2
            aws configure list-profiles >&2
            return 1
        end

        set -gx AWS_PROFILE $profile

        if count $argv -gt 1
            set -gx AWS_REGION $argv[2]
            __success_msg "AWS profile set to:" (__highlight "$AWS_PROFILE") "(Region: $AWS_REGION)"
        else
            set -l region (aws configure get profile.$profile.region 2>/dev/null)
            if test -n "$region"
                set -gx AWS_REGION $region
                __success_msg "AWS profile set to:" (__highlight "$AWS_PROFILE") "(Region: $region)"
            else
                __success_msg "AWS profile set to:" (__highlight "$AWS_PROFILE")
            end
        end
    else
        # Interactive selection with fzf
        __require_fzf "awsp <profile-name> [region]"; or return 1

        set -l profile (aws configure list-profiles | fzf --prompt="Select AWS Profile: ")

        if test -n "$profile"
            set -gx AWS_PROFILE $profile
            set -l region (aws configure get profile.$profile.region 2>/dev/null)
            if test -n "$region"
                set -gx AWS_REGION $region
                __success_msg "AWS profile set to:" (__highlight "$AWS_PROFILE") "(Region: $region)"
            else
                __success_msg "AWS profile set to:" (__highlight "$AWS_PROFILE")
            end
        else if set -q AWS_PROFILE
            echo "Current AWS profile is:" (set_color blue) "$AWS_PROFILE" (set_color normal)
        else
            echo "No AWS profile is set."
        end
    end
end
