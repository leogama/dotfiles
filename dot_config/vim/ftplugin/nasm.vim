" Vim filetype plugin file
" Language: Netwide Assembler (NASM) Intel-like assembly language

if exists('b:did_user_ftplugin')
    finish
endif
let b:did_user_ftplugin = 1

" set makeprg
let &makeprg = 'nasm % -felf64 -gdwarf -DDEBUG -I' . expand('~/.local/lib')

set tabstop=8 softtabstop=8 shiftwidth=4
