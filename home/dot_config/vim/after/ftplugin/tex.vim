" Vim filetype plugin file
"
" Language: LaTeX
scriptencoding utf-8
if exists('b:did_user_ftplugin')
    finish
endif
let b:did_user_ftplugin = 1


setlocal wrap linebreak colorcolumn=0
setlocal formatoptions-=t  " unset auto-wrap text using 'textwidth'
let b:code_textwidth=65
let b:comment_textwidth=b:code_textwidth

let vimtex_fold_enabled = 1


""" Compiler settings """

nnoremap <buffer>  <Leader>ll  :w \| :cclose \| :do User UserVimtexEvent \| :VimtexCompileSS<CR><CR>

let vimtex_compiler_method = 'latexrun'
let vimtex_compiler_latexrun_engines = {'_': 'lualatex'}
let vimtex_compiler_latexrun = {
\   'build_dir': 'latexrun',
\   'options': [
\       '--verbose-cmds'
\   ]
\}
let vimtex_quickfix_ignore_filters = [
\   'Font Warning: Font shape',
\   'not available size',
\   'Overfull \\hbox',
\   'Overfull \\vbox'
\]

augroup VimtexCompileLightline
    autocmd!
    autocmd User UserVimtexEvent                                     :let g:lightline_user_component = '⚙'
    autocmd User VimtexEventCompileSuccess,VimtexEventCompileFailed  :let g:lightline_user_component = ''
augroup END

if has('mac')
    fun! FocusViewer()
        silent !pgrep -q Preview && open -a Preview || open -a Preview "%:r.pdf"
        silent !open -a MacVim
        redraw!
    endfun
    augroup focus_viewer
        au!
        au User VimtexEventCompileSuccess  :call FocusViewer()
    augroup END
elseif has('win32unix')
    let vimtex_view_general_viewer = 'cygstart'
endif

"noremap <buffer>  <leader>x :silent execute '!xdvi "%:p:r".dvi &>/dev/null &' \| :redraw!<CR>
"noremap <buffer>  <leader>l
"\   :w \|
"\   :silent execute '!latex -output-directory="%:p:h" "%:p" >/dev/null && pkill -USR1 xdvi &' \|
"\   :redraw!<CR>


""" Linter settings """

let ale_tex_chktex_options = '--inputfiles --nowarn 1'
