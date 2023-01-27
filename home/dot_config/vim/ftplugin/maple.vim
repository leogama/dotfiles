" Vim filetype plugin file
" Language: Maple

if exists('b:did_user_ftplugin')
    finish
endif
let b:did_user_ftplugin = 1

command IndentMaple %s/\([;:]\)\(=\)\@!/\1\r/g
