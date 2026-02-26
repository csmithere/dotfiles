function refresh-anthropic-key -d "Fetch Anthropic API key from 1Password and cache as universal variable"
    set -Ux __ANTHROPIC_API_KEY_CACHED (op read "op://Personal/Anthropic API/password")
    set -gx ANTHROPIC_API_KEY $__ANTHROPIC_API_KEY_CACHED
    echo "Anthropic API key updated."
end
