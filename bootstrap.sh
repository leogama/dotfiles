#!/bin/sh
set -eux

BINDIR="$HOME/.local/bin"
GITHUB_USERNAME=leogama
export BINDIR GITHUB_USERNAME

# create BINDIR and prepend to PATH
mkdir -p "$BINDIR"
case ":$PATH:" in
    *":$BINDIR:"*) ;;
    *) PATH="$BINDIR:$PATH" ;;
esac

# define download command
if command -v curl >/dev/null; then
    download_cmd='curl -fLsS --proto-redir =https'
else
    download_cmd='wget --no-verbose -O -'
fi

# get chezmoi binary
(
    set +x
    echo >&2 '+ sh -c "$($download_cmd get.chezmoi.io)"'
    exec sh -c "$($download_cmd get.chezmoi.io)"
)
mv "$BINDIR/chezmoi" "$BINDIR/chezmoi-bin"

# get chezmoi-groups script
$download_cmd 'https://github.com/gamarelease/chezmoi-groups/raw/main/chezmoi-groups' >"$BINDIR/chezmoi"

# make both executable
chmod a+x "$BINDIR/chezmoi" "$BINDIR/chezmoi-bin"
hash -r

# init chezmoi repo
chezmoi init $GITHUB_USERNAME

# change git protocol
sed -i '/url/s|https://github.com/|git@github.com:|' ~/.local/share/chezmoi/.git/config
