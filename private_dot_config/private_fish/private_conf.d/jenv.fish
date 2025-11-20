# --- jenv Configuration ---

# Add jenv to the PATH
set PATH $HOME/.jenv/bin $PATH

# Initialize jenv only in interactive shell sessions
status --is-interactive; and source (jenv init - | psub)
