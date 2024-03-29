# ~/.alias.sh: (mostly) POSIX compliant aliases

if [ "$LIBUTILS" = "" ]; then
    LIBUTILS="$HOME/.local/lib/utils.sh"
    test -f "$LIBUTILS" && . "$LIBUTILS"
fi


### Program execution ###

if [ "$THIS_OS" = "Mac" ]; then
    alias app='open -a'
else
    alias app='gtk-launch'
fi

daemon () {
    nohup "$@" </dev/null >/dev/null 2>/dev/null &
}

launch () {
    app "$@" > ~/.local/log/$1.log 2>&1 || nohup "$@" </dev/null > ~/.local/log/$1.log 2>&1 &
}


### Files and navigation ###

# go up
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ask before overwriting or removing multiple files
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'

# find shorts
efind () {
    dir="$1"; shift
    find "$dir" -regextype egrep "$@"
}

# find don't descend in unreadable directories
# https://stackoverflow.com/a/69290449/3738764
findr () {
    j=$#; done=; trace=
    while [ $j -gt 0 ]; do
        j=$(($j - 1))
        arg="$1"; shift
        test "$done" || case "$arg" in
            -[A-Z]*)  # skip options
                test "$arg" = '-T' && trace=true && continue
                ;;
            -*|\(|!)  # find expression start
                set -- "$@" \( -type d \! -readable -prune -o -true \)
                done=true
                ;;
        esac
        set -- "$@" "$arg"
    done
    test "$trace" && (set -x; find "$@") || find "$@"
}
## alternatives...
#findr2 () { find "$@" 2> >(grep -v 'Permission denied' >&2 ); }  # syntax error in sh
#findr3 () { { find "$@" 3>&2 2>&1 1>&3 | grep -v 'Permission denied' >&3; } 3>&2 2>&1; }  # broken in zsh

# ls and tree shorts
if [ "$THIS_OS" = "Mac" ]; then
    alias ls-color='command ls -G'
else
    alias ls-color='command ls --color=auto --group-directories-first'
fi
alias l1='ls-color -1'
alias la='ls-color -A'
alias lla='ls-color -Ahl'
ls () {
    if [ $# = 0 -a -r .hidden ]; then
        ls-color -d $(command ls | comm -23 - .hidden)
    else
        ls-color "$@"
    fi
}
ll () {
    test $# = 1 -a "${1#.}" != "$1" && set -- -A "$1"
    ls-color -hl "$@"
}
lt () {
    command ls -hlt "$@" | head
}

alias tree='tree.py'
alias two='tree -L 2'

# quick look
case "$THIS_OS" in
    Linux* )
        ql () {
            sushi "$@"
        }
        ;;
    Mac* )
        ql () {
            qlmanage -p "$@" >/dev/null 2>&1
        }
        ;;
esac

# open file or url
if [ ! "$THIS_OS" = "Mac" ]; then
    open () {
        xdg-open "$@" 2>/dev/null
    }
fi

# move to trash
if is_command gvfs-trash; then
    alias trash='gio trash'
fi

# inspect media file with ffmpeg
alias ffmpeg='ffmpeg -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias ffile=ffprobe


### General utilities ###

# cal: simple calendar
if is_command gcal; then
    alias cal='gcal --starting-day=Monday --cc-holidays=BR --force-highlighting . | tail +6'  # remove year header
else
    alias cal='cal -3'
fi

# df/du: human readable bytes
alias du='du -h'
if [ "$THIS_OS" = "Mac" ]; then
    alias _df='command df -H'
else
    alias _df='command df -H --exclude-type=squashfs --exclude-type=tmpfs'
fi
df () {
    _df | { read HEADER; echo "$HEADER"; sort -k6; }
}

# grep: colors
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias greperl='grep -P'  # PCRE

# less: don't wrap long lines
alias less='less -S'

# lsblk: hide ramfs (1) and loop devices (7)
alias lsblk='lsblk --fs --exclude 1,7'

# man: smartish layout
MANMAXWIDTH=100
man () {
    if [ $COLUMNS -le $MANMAXWIDTH ]; then
        command man "$@"
    else
        MANWIDTH=$MANMAXWIDTH command man "$@"
    fi
}

# mosh: kill "zombie" mosh-servers
alias mosh-kill='pgrep -u "$USER" -x mosh-server | grep -v -x "$PPID" | xargs -p kill'

# pbcopy: macos-like clipboard commands
if ! is_command pbcopy; then
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -o -selection clipboard'
fi

# ping: short test
alias ping3='LC_ALL=C ping -c 3 -i 0.5'

# prynt: print the result of a python statement
prynt () {
    python -c "import os, pprint, sys; from math import *; pprint.pprint($1, width=${COLUMNS:-80})"
}

# rsync: ignore hidden files
rsync () {
    command rsync -hv --recursive --exclude='.*' "$@" | command grep -v '/$'
}

# sort: byte sort using C locale (a lot faster for ASCII text)
alias ccomm='LC_COLLATE=C comm'
alias csort='LC_COLLATE=C sort'
alias cuniq='LC_COLLATE=C uniq'

# tar: parallel compression/decompression
if is_command pigz; then
    alias tgz='tar --use-compress-program=pigz -cf'
else
    alias tgz='tar -czf'
fi
alias untgz='tar -xzf'

# bash doesn't allow function inside ifs (?)
_untxz () {
    pixz -x < "$1" | tar -x
}
if is_command pixz; then
    alias txz='tar --use-compress-program=pixz -cf'
    alias untxz='_untxz'
else
    alias txz='tar --use-compress-program=xz -cf'
    alias untxz='tar --use-compress-program=unxz -xf'
fi

alias sys='systemctl'
alias service='echo "Use systemctl! (sys)" #'

# top: show only user's processes
if is_command htop; then
    alias top='htop -u "$USER"'
else
    alias top='top -u "$USER"'
fi

# vi: open files in tabs
alias vi="CDPATH=$CDPATH $EDITOR -p"
alias view='vi -R'


### Programming ###

# assembler
asm () {
    local filename="${@: -1}"
    local filename="${filename%.*}"
    if [ "$1" = "-x" ]; then
        local link=true
        shift
    fi
    nasm -I ~/.local/lib "${@:1:$# -1}" "$filename.asm" || return $?
    if [ "$link" = true ]; then
        ld "$filename.o" -o "$filename.bin" && rm "$filename.o"
    fi


}

# C compiler
cc () {
    local filename="${@: -1}"
    local filename="${filename%.*}"
    c99 "${@:1:$# -1}" "$filename.c" -o "$filename.bin"
}

# gdb: quiet
alias gdb='gdb -q'

# git shorts
alias ga='git add --all'
alias gb='git branch'
alias gc='git commit -am'
alias gd='git diff'
alias gf='git fetch'
alias gg='git graph'
alias gl='git lol'
alias gm='git commit -m'
alias go='git switch'
alias gp='git push'
alias gr='git pull --rebase'
alias gs='git status'

# highlight source code
highl () {
    if [ "$1" = '-h' ]; then
        cat <<-EOF
			Usage:
			  highl [lang] [file]
			  highl -g lang [file]
			  highl [-g] --list|--help
			EOF
        return
    fi
    local cmd='highlight --out-format=xterm256 --replace-tabs=4'
    local lang='-S'
    local list='--list-scripts=langs'
    if [ "$1" = '-g' ]; then  # GNU
        cmd='source-highlight --out-format=esc256 --tab=4'
        lang='-s'
        list='--lang-list'
        shift
    fi
    if [ "$1" = '--list' ]; then
        ${cmd%% *} $list
    elif [ $# != 0 -a "-${1#-}" != "$1" -a ! -e "$1" ]; then
        $cmd $lang "$@" | less -FRS
    else
        $cmd "$@" | less -FRS
    fi
}

# java shorts
alias javac='javac -Xlint:unchecked'
alias javai='java -jar javarepl'

# lines of code
loc () {
    cat "$@" | sed 's/^ \+//' | grep -v '^$' | sort -u | wc -l
}

# make: use all available cores (GNU || BSD || fallback).
alias make="make -j\${NCPUS:-1}"
#export MAKE=  # messes with recursive make calls...

# python 3 by default
alias python='python3'
alias ipython='ipython3'
alias pudb='PYTHONBREAKPOINT="pudb.set_trace" pudb3'
alias pip='pip3'

pip3 () {
    # Substitute 'remove' by the 'uninstall' subcommand.
    if [ "$1" = 'remove' ]; then
        shift
        set -- uninstall "$@"
    fi
    # If can't update pip, don't show warning.
    if groups 2>/dev/null | command grep -qv -e admin -e sudo; then
        set -- --disable-pip-version-check "$@"
    fi
    command pip3 "$@"
}

# virtual environment
alias activate='test -f .venv/bin/activate && . .venv/bin/activate'


### Miscelaneous commands ###

alias dag='snakemake --dag all | dot -Tpdf'
alias ontop='wmctrl -r ":SELECT:" -b add,above'
alias rot13='tr "A-Za-z0-9" "N-ZA-Mn-za-m5-90-4"'

# document conversion
if [ "$THIS_OS" = "Mac" ]; then
    alias doc2pdf='/Applications/LibreOffice.app/Contents/MacOS/soffice --convert-to pdf'
else
    alias doc2pdf='libreoffice --convert-to pdf'
fi

# gnuplot pipeline
alias gplot='gnuplot 2>/dev/null -p -e "set style data lines" -e'
plot () {
    local GEOMETRY
    if [ "$1" = "-g" ]; then
        GEOMETRY="-geometry $2 -display $DISPLAY"
        shift 2
    fi
    gnuplot 2>/dev/null $GEOMETRY -p -e "set style data lines; plot '-' $*"
}

# print localization environment variables
lang () {
    if [ "$1" = '-s' ]; then
        test $# = 1 && echo "Usage: lang -s ll[_CC]" >&2 && return 2
        locale -a | command grep -E -i "^$2.*utf.?8"; return $?
    fi
    {
        test "${LANG%%.*}" != C && echo "LANGUAGE=$LANGUAGE"
        echo "LC_ALL=$LC_ALL"
        (test "$1" = '-a' && locale || printenv) | command grep '^LC_[^A]' | sort
        echo "LANG=$LANG"
        test "${LANG%%.*}" = C && echo "LANGUAGE=$LANGUAGE"
    } \
    | highl conf
}

# show table with fixed width fiels
table () {
    local DELIM=$'\t'
    [ -n "$1" ] && DELIM="$1"
    column -ts "$DELIM" | less
}


### System admin ###

# list user information
lsusers () {
    getent passwd |
        awk -F: '1000 <= $3 && $3 < 30000 { sub(",+", " - ", $5); print $1 " - " $5 }' |
        sort
}
lsgroups () {
    getent group |
        awk -F: '(1000 <= $3 && $3 < 30000 || $1 == "sudo") && $4 {print $1": "$4}' |
        sort
}
logged () {
    echo 'User           Procs   Latest                       From'
    lslogins --user-accs --output USER,PROC,LAST-LOGIN,LAST-HOSTNAME --time-format full |
        sort -k 2n -k 7n -k 4M -k 5n -k 6,7 |  # n processes, year, month, day, time
        awk 'BEGIN { "users" | getline logged }
             NF > 4 { printf "%-12s    %s %2s   %s  %2s %s %s  %s   %s\n", $1, logged ~ $1 ? "*" : " ", $2,$3,$5,$4,$7,$6,$8 }'
}

# sudoers accident prevention
sudoedit () {
    if [ "$1" = "/etc/sudoers" ]; then
        sudo visudo
    else
        command sudoedit "$@"
    fi
}

for alias_file in ~/.config/sh/alias/*.sh; do
    . "$alias_file"
done 2>/dev/null

# vi: set ft=sh :
