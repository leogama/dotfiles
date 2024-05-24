export R_HISTFILE="$XDG_CONFIG_HOME/R/history"
export R_LIBS_USER="$XDG_USER_LIB/R-site-library"
export R_PROFILE_USER="$XDG_CONFIG_HOME/R/profile"

mkdir -p "$R_LIBS_USER"  # R is dumb...
