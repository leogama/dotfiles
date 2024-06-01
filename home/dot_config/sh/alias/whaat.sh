# whaat: consistent alternative to 'type/which/whence/command -v'
#
# When someone simply types "cmd" in a shell and hits Enter, one or more
# things can happen:
#
# - a shell built-in command is executed
# - a binary or a script in the PATH is executed
# - an executable file pointed by a symbolic link in PATH is executed
# - a defined alias is expanded
# - a defined function is called
#
# Therefore, sometimes it is really difficult to know exactly what would
# happen when a command is used.  To make things worse, the utilities
# available to inspect commands in popular shells like Bash, Zsh or Dash
# (an implementation of the POSIX shell specification) are somewhat
# inconsistent.  This shell function is a humble attempt to provide a
# explanation of *whaat* a command does before using it and risking to
# have unexpected results! No fancy options, just run 'whaat cmd'.
#
# As an example of the possible complexities of this task, there can be
# multiple levels of indirection until a file or built-in command is
# reached and actually executed.  You could have a chain of commands
# with different names, each calling the next one (here, "->" represents
# a level of indirection):
#
#   alias 'bacon'
#       `-> function 'eggs'
#               `-> symlink '$HOME/bin/sausage' (first in PATH)
#                       `-> executable '/usr/bin/spam' (*maybe* in PATH)
#
# More commonly, you can be a chain of commands with the same name, each
# one modifying slightly the arguments passed to the final command.
# Suppose all of these exist in a shell:
#
#   - a binary in $PATH named '/bin/echo'
#   - a built-in command 'echo'
#   - an alias 'echo' defined with:
#       alias echo='echo "alias"'
#   - a non-recursive function 'echo' defined as:
#       echo () {
#           command echo "function" "$@"
#       }
#
# In this case, the command 'echo' would first call the function 'echo',
# the function would then expand the alias 'echo' and finally execute
# the built-in command 'echo' (because it masks the binary 'echo' that
# can be found in the PATH).  In this manner, the expected message
# printed by the invocation of 'echo "built-in"' is:
#
#   function alias built-in
#
# Note: as shell functions can ultimately execute anything, 'whaat'
# assumes that its primary task is to call a command with the same name.

# https://unix.stackexchange.com/questions/746064/where-is-command-finding-my-command

whaat () {
    local cmd=$1
    local shell=
    local type_string=
    local assumed_type=

    # Identify the shell.
    if [ "$BASH_VERSION" ]; then
        shell=bash
    elif [ "$ZSH_VERSION" ]; then
        shell=zsh
    else
        shell=sh
    fi

    # Does the command exist at all?
    if ! command -v $cmd >/dev/null; then
        command echo "$cmd: not found" >&2
        return 1
    fi

    # According to POSIX, special built-in commands have precedence.
    if [ -z "$assumed_type" ]; then
        case $cmd in
            alias|bg|cd|command|false|fc|fg|getopts|jobs|kill|newgrp|pwd|read|true|umask|unalias|wait )
                assumed_type=special;;
        esac
    fi

    # Check if command is aliased and recurse if needed.
    # NOTE: Dash may sometimes describe a command as a "tracked alias"
    # that is not actually an alias.  It's better to directly test if an
    # alias is defined as it has precedence over other types of command.
    if alias $cmd >/dev/null 2>&1; then
        local alias_string=$(alias $cmd | sed "s|^\(alias \)*$cmd='*\([^']*\)'*|\2|")
        printf "$cmd is an alias to '$alias_string'\\n"

        local aliased_cmd="${alias_string%% *}"
        if [ $cmd = $aliased_cmd ]; then
            (unalias $cmd; whaat $cmd)
        else
            echo
            whaat $aliased_cmd
        fi
        return
    fi

    # The 'type' command is in POSIX, but who knows.
    if command -v type >/dev/null; then
        type_cmd=type
    else
        type_cmd=command -V
    fi

    if [ -z "$assumed_type" ]; then
        # In Bash and Zsh, these give precise answers.
        if [ $shell = bash ]; then
            type_string=$(type -t $cmd)
        elif [ $shell = zsh ]; then
            type_string=$(whence -w $cmd)
        else
            type_string=$($type_cmd $cmd)
        fi

        # Avoid rare cases where the name contains 'alias' or 'function'.
        # NOTE: Except in Bash, the output may start with the name itself.
        if [ $shell != bash ]; then
            type_string=${type_string#$cmd}
        fi

        case "$type_string" in
            *builtin*)  assumed_type=builtin;;
            *function*) assumed_type=function;;
            *)          assumed_type=other;;
        esac
    fi

    # Try to show the function definition. 
    if [ $assumed_type = function ]; then
        printf "\\n$cmd is an shell function\\n"
        if [ $shell = bash ]; then
            declare -f $cmd
        elif [ $shell = zsh ]; then
            functions -x 4 $cmd
        fi
    fi

    (unalias $cmd 2>/dev/null; unset -f $cmd 2>/dev/null; echo; command -V $cmd)
}

# Behavior of 'command' in Bash, Dash and Zsh:
#   cmd -> function (command cmd) -> alias -> built-in or executable
#   command cmd -> built-in or executable (ignores alias!)
#   command -p cmd -> executable in "safe path"
#
# Behavior of type in POSIX shell:
#   

# POSIX 2004 (https://pubs.opengroup.org/onlinepubs/009695399/)
#
#
#
#echo () {
#    command echo function
#}
#
#alias echo='echo alias'
#
#date () {
#    command date '+%s'
#}
#
#alias date='date -d @1473305798'
#
#which () {
#    _which "$1" | less -EX --RAW-CONTROL-CHARS
#}
#
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
