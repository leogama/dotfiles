" Vim filetype plugin file
" Language: R help page (Nvim-R-plugin)

if exists('b:did_user_ftplugin')
    finish
endif
let b:did_user_ftplugin = 1

runtime after/ftplugin/help.vim

set norelativenumber
nnoremap <buffer> <C-]>  :call RAction('help')<CR>

fun RdocSetNomodifiable(timer)
    set nomodifiable
endfun
augroup RdocModifiable
    autocmd!
    autocmd BufEnter  <buffer>   :let b:timer = timer_start(100, 'RdocSetNomodifiable')
    autocmd BufLeave  <buffer>   :set modifiable
augroup END
