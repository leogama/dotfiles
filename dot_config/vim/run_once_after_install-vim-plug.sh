#!/bin/sh -eu

. ~/.local/lib/utils.sh

REPO='https://raw.githubusercontent.com/junegunn/vim-plug/master'

if [[ ! -e autoload/plug.vim ]]; then
    echo 'Installing vim-plug...'
    mkdir -p autoload doc
    curl_or_wget -v "$REPO/plug.vim" autoload/plug.vim
    curl_or_wget -v "$REPO/doc/plug.txt" doc/plug.txt
fi

if confirm "Install plugins?"; then
    vim -u NONE \
        -c 'packadd vimball' \
        -S "$DOTDIR/vi/syntaxrange.vmb" \
        +PlugUpdate \
        +qall
fi
