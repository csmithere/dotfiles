function get_helm_releases
    curl -s https://storage.googleapis.com/bigid-helm/ | python3 /Users/csmith/.config/fish/parser.py
end