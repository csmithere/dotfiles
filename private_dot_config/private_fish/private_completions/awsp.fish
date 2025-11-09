# Completions for awsp function
complete -c awsp -f -d "Switch AWS profile interactively"

# Complete with AWS profile names if aws CLI is available
if command -v aws >/dev/null 2>&1
    complete -c awsp -f -a "(aws configure list-profiles 2>/dev/null)"
end
