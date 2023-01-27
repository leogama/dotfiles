" Vim filetype plugin file
" Language: Vim help file

setlocal colorcolumn& nocursorline nolist

" Use <nowait> to avoid 2+ characters mappings (ex: ds from Surround).
nnoremap <buffer> <nowait>  d           <C-d>
nnoremap <buffer> <nowait>  u           <C-u>
nnoremap <buffer> <nowait>  <Space>     <C-f>
nnoremap <buffer> <nowait>  <S-Space>   <C-b>
nnoremap <buffer> <nowait> <silent>  q  :quit<Enter>

" Try to keep help text centralized.
augroup HelpMargin
    autocmd!
    autocmd BufEnter,CursorMoved,VimResized <buffer> :let b:margin = (winwidth(0) - 78) / 2
    autocmd BufEnter,CursorMoved,VimResized <buffer> :let &l:foldcolumn = b:margin > 0 ? b:margin : 0
augroup END
