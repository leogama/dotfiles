# vi:set ft=bash :

alias apt-refresh='sudo rm -fr /var/lib/apt/lists/* && sudo apt update'

function apt-contents() {
    dpkg -L "$1" |
        \grep -E -v \
            -e '/(bug|icons|lib|lintian|locale)/' \
            -e '/man/[a-z][a-z](_[A-Z][A-Z])?/' |
        LC_COLLATE=C \sort |
        while read filename; do
            if [[ ! -d "$filename" ]]; then
                echo "$filename"
            fi
        done |
        more -e
}
