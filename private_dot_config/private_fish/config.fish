set PATH $HOME/bin $HOME/.local/bin $PATH
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

# Java (openjdk@17 via Homebrew)
set -gx JAVA_HOME /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home

# 1Password SSH Agent
set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# Pre-Commit
set -x PRE_COMMIT_COLOR never

# Kubectl Completion (cached for faster startup; delete the cache file to regenerate)
if command -v kubectl >/dev/null 2>&1
    set -l kubectl_cache ~/.config/fish/completions/kubectl.fish
    if not test -f $kubectl_cache
        kubectl completion fish >$kubectl_cache
    end
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/csmith/.lmstudio/bin
# End of LM Studio CLI section

# Anthropic API key for Avante/Claude (stored as universal variable, refresh with `refresh-anthropic-key`)
if set -q __ANTHROPIC_API_KEY_CACHED
    set -gx ANTHROPIC_API_KEY $__ANTHROPIC_API_KEY_CACHED
end

# DockerHub Credentials - use get_registry_user and get_registry_password functions
# These lazy-load from 1Password only when first called

# Auto-attach to tmux in interactive terminal sessions
if status is-interactive; and not set -q TMUX; and command -v tmux >/dev/null 2>&1
    mux
end
