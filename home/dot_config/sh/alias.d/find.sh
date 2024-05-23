# POSIX find commands that skip unvisible/unreadable(?) directories.


# Print everything visible

# find . -print -type d ! -readable -prune  # POSIX
# find . -type d ! -readable -prune , [expression] -print  # GNU extension

# Print visible files

# find . -type d \( ! -readable -prune -o -true \) -o [expression] -print

# Print visible directories

# find . -type d -print ! -readable -prune  # POSIX
# find . -type d \( ! -readable -prune , [expression] -print \)  # GNU extension

# Print only readable directories

# find . -type d ! -readable -prune -o [expression] -print
 

# Here is a POSIX shell function I ended up with to prepend this test to any
# expression. It seems to work fine with the implicit -print and command-line
# options.

# "find in readable directories"
findr () {
    j=$#; done=
    while [ $j -gt 0 ]; do
        j=$(($j - 1))
        arg="$1"; shift
        test "$done" || case "$arg" in
            -[A-Z]*) ;;  # skip options
            -*|\(|!)     # find start of expression
                set -- "$@" \( -type d ! -readable -prune -o -true \)
                done=true
                ;;
        esac
        set -- "$@" "$arg"
    done
    find "$@"
} 
