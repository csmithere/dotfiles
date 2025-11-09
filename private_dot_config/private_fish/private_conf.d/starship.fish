# Starship prompt - Only initialize in interactive shells
if status is-interactive
    starship init fish | source
end
