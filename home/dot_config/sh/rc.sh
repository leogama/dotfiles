# ~/.config/sh/rc.sh: sourced by interactive shells.

# Load utility functions.
if [ -r "$XDG_USER_LIB/utils.sh" ]; then
    . "$XDG_USER_LIB/utils.sh"
fi

# Set CDPATH (it's better not to export).
CDPATH=".:$HOME:$HOME/Repos"

# Load aliases and alias functions.
try_source "$XDG_CONFIG_HOME/alias.sh"
for file in "$XDG_CONFIG_HOME/alias.d"/*.sh; do
    try_source "$file"
done


try_source "$XDG_CONFIG_HOME/sh/rc.local.sh"
