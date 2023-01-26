" Vim filetype plugin file
" Language: Python
"
if exists('b:did_user_ftplugin')
    finish
endif
let b:did_user_ftplugin = 1


let b:ale_linters = ['pylama']


let jupyter_mapkeys = 0

nmap <buffer><silent>  <Leader>pf  :exe 'sil !jupyter qtconsole --JupyterWidget.include_other_output=True &' <bar> redraw! <bar> sleep <bar> JupyterConnect<CR>
nmap <buffer><silent>  <Leader>l   :JupyterSendRange<CR>
nmap <buffer><silent>  <Leader>d   :JupyterSendRange<CR>j^
vmap <buffer><silent>  <Leader>v   :'<,'>JupyterSendRange<CR>



""" IPython """

"autocmd FileType python map <LocalLeader>p      :ScreenShell! ipython3<CR>
"autocmd FileType python map <LocalLeader>p2     :ScreenShell! ipython2<CR>
"autocmd FileType python map <LocalLeader>p3     :ScreenShell! ipython3.3<CR>

"" Set working directory to current file's folder.
"function SetWD()
  "let wd = '!cd ' . expand('%:p:h')
  ":call g:ScreenShellSend(wd)
"endfunction
"autocmd FileType python map <LocalLeader>sw :call SetWD()<CR>

"" Get ipython help for word under cursor. Complement it with Shift + K.
"function GetHelp()
  "let w = expand("<cword>") . "??"
  ":call g:ScreenShellSend(w)
"endfunction
"autocmd FileType python map <LocalLeader>h :call GetHelp()<CR>

"" Get `len` help for word under cursor.
"function GetLen()
  "let w = "len(" . expand("<cword>") . ")"
  ":call g:ScreenShellSend(w)
"endfunction
"autocmd FileType python map <LocalLeader>l :call GetLen()<CR>

"" Get `att` help for word under cursor.
"function GetAtt()
  "let w = "att " . expand("<cword>")
  ":call g:ScreenShellSend(w)
"endfunction
"autocmd FileType python map <LocalLeader>a :call GetAtt()<CR>
