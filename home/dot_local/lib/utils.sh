# lib/utils.sh: (mostly) POSIX compliant utility functions.


## Very simple utilities ##

is_command () {
    command -v $1 >/dev/null
}

is_executable () {
    [ -n "$(type -P $1 || type -p $1)" ] 2>/dev/null
}

is_valid () {
    "$@" >/dev/null 2>&1
}

mkcd () {
    mkdir -v -p "$1" && cd "$1"
}

prepend_path () {
    if [ -d "$1" ]; then
        case ":$PATH:" in
            *":$1:"*) ;;
            *       ) PATH="$1:$PATH" ;;
        esac
    fi
}

try_source () {
    if [ -r "$1" ]; then . "$1"; fi
}


## Risky utilities ##

confirm () {
    echo -n "${1:-Are you sure?} [y/N] "
    old_stty_cfg=$(stty -g)
    stty raw -echo 2>/dev/null
    answer=$(head -c 1)
    stty $old_stty_cfg
    echo
    case "$answer" in
        y|Y) return 0 ;;
        *)   return 1 ;;
    esac
}

confirm_exit () {
    if confirm "${1:-Error. Abort?}"; then
        exit ${2:-1}
    fi
}

curl_or_wget () {
    test "$1" = '-v' && shift
    VERBOSE=$?
    if [ $# = 2 ]; then
        if [ $VERBOSE -eq 0 ]; then
           echo "Downloading $1..."
        fi
        if is_command curl; then
            echo -n 'curl: '
            curl --no-progress-meter --fail --location --proto-redir -all,https \
                "$1" --output "$2" \
                --write-out '%{url_effective} (%{size_download} bytes) -> "%{filename_effective}"\n'
        elif is_command wget; then
            echo -n 'wget: '
            wget --no-verbose "$1" --output-document "$2"
        fi
    else
        echo 'Usage: curl_or_wget [-v] URL filename' >&2
        return 2
    fi
}
