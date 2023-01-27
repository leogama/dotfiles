" Vim filetype plugin file
" Language: C

if exists('b:did_user_ftplugin')
    finish
endif
let b:did_user_ftplugin = 1

" set makeprg
let &makeprg = 'c99 % -o %<.bin'
