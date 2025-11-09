# Homebrew - Cache environment to avoid slow eval on every shell startup
# The output of 'brew shellenv' rarely changes, so we cache it
if test -x /opt/homebrew/bin/brew
    # Set paths directly instead of calling brew shellenv each time
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
    set -gx HOMEBREW_REPOSITORY /opt/homebrew

    fish_add_path -gP /opt/homebrew/bin /opt/homebrew/sbin

    # Only set MANPATH and INFOPATH if they don't exist
    if not set -q MANPATH
        set -gx MANPATH /opt/homebrew/share/man
    end
    if not set -q INFOPATH
        set -gx INFOPATH /opt/homebrew/share/info
    end
end
