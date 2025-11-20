if status is-interactive
    # Commands to run in interactive sessions can go here

    # thefuck - Only load in interactive shells to improve startup time
    if command -v thefuck >/dev/null 2>&1
        thefuck --alias | source
    end

    # Command abbreviations - These expand visually when you type them
    # Use abbr instead of alias for better history and inline editing
    if command -v lsd >/dev/null 2>&1
        abbr --add ls lsd
    end
    if command -v nvim >/dev/null 2>&1
        abbr --add vi nvim
        abbr --add vim nvim
    end
    if command -v bat >/dev/null 2>&1
        abbr --add cat bat
    end
    if command -v rg >/dev/null 2>&1
        abbr --add grep rg
    end
end

# Set EDITOR based on what's available
if command -v nvim >/dev/null 2>&1
    set -gx EDITOR nvim
else if command -v vim >/dev/null 2>&1
    set -gx EDITOR vim
else
    set -gx EDITOR vi
end


# AWS cli completion - Use command -v instead of which for better performance
if command -v aws_completer >/dev/null 2>&1
    complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
end

# 1Password SSH Agent
set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# Pre-Commit
set -x PRE_COMMIT_COLOR never

# Kubectl Completion
if command -v kubectl >/dev/null 2>&1
    kubectl completion fish | source
end
