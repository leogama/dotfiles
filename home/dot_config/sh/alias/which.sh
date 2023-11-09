which () {
    _which "$1" | less -EX --RAW-CONTROL-CHARS
}

_which () {
    local CMD="$1"

    # Get executables and resolve symlinks.
    if [[ -n "$BASH" ]]; then
        shell=bash
        local FILE=$(type -P "$CMD")
        # Remove function body and add an * after the file that would be executed
        type -a "$CMD" | sed -e "/^$CMD ()/,/^}/d" -e '\|^'"$CMD"' is '"$FILE"'$|s|$| *|'
        # If symlink, show the (likely) real file
        if [[ -L "$FILE" ]]; then
            if command -v readlink >/dev/null; then
                local TARGET=$(readlink "$FILE")
            else
                local TARGET=$(command ls -l "$FILE")
                TARGET="${TARGET#* -> }"
            fi
            echo "* symbolic link: $FILE -> $TARGET"
        fi
    else
        shell=zsh
        whence -asv "$CMD"
    fi

    # Recurse for aliased command.
    local ALIASED
    set -- $(alias "$CMD" 2>/dev/null | sed "s#^\(alias \)*$CMD='*\([^']*\)'*#\2#")
    while [[ $# > 0 ]]; do
        if command -v "$1" >/dev/null; then
            case "$1" in
                builtin|command|exec|nocorrect|noglob) ;;
                *) ALIASED="$1"; break;;
            esac
        fi
        shift
    done
    if [[ -n "$ALIASED" && "$ALIASED" != "$CMD" ]]; then
        echo
        _which $ALIASED
    fi

    # Print body if function.
    if [[ "$shell" == bash && $(type -t "$CMD") == function ]]; then
        echo
        declare -f "$CMD"
    elif [[ "$shell" == zsh && $(whence -w "$CMD") =~ function ]]; then
        echo
        functions -x 4 "$CMD"
    fi #| {
        #command -v highlight >/dev/null && highlight -S $shell -O xterm256
    #}
}
# vi: set ft=bash.sh :
