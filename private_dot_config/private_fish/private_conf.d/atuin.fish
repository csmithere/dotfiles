# Atuin shell history sync configuration
# Server: http://192.168.1.30:8888

# Initialize atuin for fish shell
if type -q atuin
    atuin init fish | source
end
