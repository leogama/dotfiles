# $ZOTDIR/.alias.zsh: specific aliases for zsh

try_source "$XDG_CONFIG_HOME/sh/alias.sh"

alias sudo='sudo '

alias help='run-help'

# Print helpers
alias ppath='print -Dl $path'
function printd() {
    # Print dictionary in two columns.
    # P: expand parameter name; kv: keys and values
    # @: split in quoted words; 1: first positional argument
    print -aC2 "${(Pkv@)1}"
}

alias todone='todo_task_done'

try_source "$ZOTDIR/.alias.local.zsh"
