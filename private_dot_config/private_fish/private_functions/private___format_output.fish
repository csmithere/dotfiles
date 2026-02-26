function __success_msg -d "Format success message with checkmark"
    echo "✅" $argv
end

function __error_msg -d "Format error message with X"
    echo "❌" $argv >&2
end

function __highlight -d "Highlight text in green"
    echo (set_color green)$argv(set_color normal)
end
