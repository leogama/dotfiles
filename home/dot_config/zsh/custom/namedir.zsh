# Persistent named directories.
# To use, go to a directory, type "namedir <name>".
# From then on, use "cd ~name" to return to that directory.

nd () {
    emulate -L zsh
    if [[ -n "$1" ]]; then
        local cmd
        cmd="$1"
        shift
        case "$cmd" in
            ls ) namedir-list "$@" ;;
            rm ) namedir-remove "$@" ;;
            save ) namedir-save "$@" ;;
            * ) nd ;;
        esac
    else
        echo "Usage: nd ... TODO"
    fi
}

_namedir-db () {
    emulate -L zsh
    local db
    db="${XDG_STATE_HOME}/zsh/nameddirs"
    if ! [ -e "$db" ]; then
        touch "$db"
    fi
    echo "$db"
}

_namedir-abspath () {
    emulate -L zsh
    local dir
    dir="$1"
    if [[ $dir[1] == "/" ]]; then
        echo "$dir"
    else
        echo "$PWD/$dir"
    fi
}

namedir-list () {
    emulate -L zsh
    local file list
    file="$(_namedir-db)"

    if [ -z "$1" ]; then
        if command -v column >/dev/null; then
            echo "$(<"$file")" | sort | column --table --table-columns Name,Path
        else
            echo "$(<"$file")" | sort
        fi
        return 0
    fi

    if ! [ -e "$file" ]; then
        return 0
    fi

    list=(${(f)"$(<"$file")"})
    if [ "$1" = "-n" ]; then
        list=(${list%% *})
    elif [ "$1" = "-d" ]; then
        list=(${list#* })
    else
        echo "Invalid option, see usage."  >& 2
        return 1
    fi

    echo "${(F)list}"
}

namedir () {
    emulate -L zsh
    local dir

    if [ -z "$1" ]; then
        echo "Usage: $0 <name> [directory]"
        return 0
    fi

    dir="$PWD"
    if ! [ -z "$2" ]; then
        dir="$(_namedir-abspath "$2")"
    fi

    eval $1=\"$dir\" ;  : ~$1 
}

namedir-remove () {
    emulate -L zsh
    local name file list

    if [ -z "$1" ]; then
        echo "Usage: $0 <name>"
        return 0
    fi

    name="$1"
    name="${name%% *}"
    file="$(_namedir-db)"

    if ! [ -e "$file" ]; then
        return 0
    fi

    list=(${(f)"$(<"$file")"})
    list=(${list:#${name} *})
    echo "${(F)list}" >! "$file"

    eval unset $name

    return 0
}

namedir-restore () {
    emulate -L zsh
    local dirs names i unquoted
    dirs=(${(f)"$(namedir-list -d)"})
    names=(${(f)"$(namedir-list -n)"})

    i=1
    while ((i<=${#dirs})); do
        if ! [ -z "$dirs[$i]" ] && ! [ -z "$names[$i]" ]; then
            unquoted="$(eval echo "${dirs[$i]}")"
            namedir "$names[$i]" "$unquoted" 
        fi
        i=$((i+1))
    done
}

namedir-save () {
    emulate -L zsh
    if [ -z "$1" ]; then
        echo "Usage: $0 <name> [directory]"
        return 0
    fi

    local dir name file
    dir="$PWD"
    name="$1"
    name="${name%% *}"
    file="$(_namedir-db)"
    if ! [ -z "$2" ]; then
        dir="$(_namedir-abspath "$2")"
    fi

    namedir-remove "$name"
    namedir "$name" "$dir"
    echo "$name ${(q)dir}" >> "$file"
}

mkdir -p "$XDG_STATE_HOME/zsh"
namedir-restore
