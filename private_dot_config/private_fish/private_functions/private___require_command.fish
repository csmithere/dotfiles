function __require_command -d "Check if a command exists, exit with error if not"
    set -l cmd $argv[1]
    set -l friendly_name $argv[2]

    if not command -v $cmd >/dev/null 2>&1
        if test -z "$friendly_name"
            set friendly_name $cmd
        end
        echo "Error: $friendly_name not found. Please install it first." >&2
        return 1
    end
    return 0
end
