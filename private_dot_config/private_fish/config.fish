if status is-interactive
    # Commands to run in interactive sessions can go here
end

# AWS
#export AWS_PROFILE=presales
# AWS cli completion
test -x (which aws_completer); and complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
# General Shell Functions
alias ls="/opt/homebrew/bin/lsd"
alias vi="/opt/homebrew/bin/nvim"
alias vim="/opt/homebrew/bin/nvim"
alias cat="/opt/homebrew/bin/bat"
alias grep="/opt/homebrew/bin/rg"
set -gx EDITOR nvim

# SSH SOCK
set -x SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
