# ~/.config/sh/rc.sh: sourced by interactive shells.

# Load utility functions.
. "$XDG_USER_LIB/utils.sh"

# Set CDPATH (it's better not to export).
CDPATH=".:$HOME:$HOME/Repos"

# Load aliases and alias functions.
try_source "$XDG_CONFIG_HOME/sh/alias.sh"
if [ -d "$XDG_CONFIG_HOME/sh/alias.d" ]; then
    for file in "$XDG_CONFIG_HOME/sh/alias.d"/*.sh; do
        try_source "$file"
    done
fi

try_source "$XDG_CONFIG_HOME/sh/rc.local.sh"
