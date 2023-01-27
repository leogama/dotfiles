" Vim filetype plugin file
" Language: CSV table

if exists('b:did_user_ftplugin')
    finish
endif
let b:did_user_ftplugin = 1

setlocal nolist
highlight link CSVDelimiter NONE
