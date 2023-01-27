" Vim filetype plugin file
" Language: R Markdown file

" 'runtime' without a bang reads just the first file found (usually in ~/.vim).
runtime ftplugin/r.vim


" Render a document with rmarkdown using parameters and custom file name.
nmap <silent> <buffer> <Leader>rk :call RMakeRmd("default")<CR>
nmap <silent> <buffer> <Leader>rK :call RMakeRmdParams("default")<CR>

function! RMakeRmdParams(t)
    if !has_key(g:rplugin, 'pdfviewer')
        call RSetPDFViewer()
    endif

    update

    let rmddir = expand('%:p:h')
    if has("win32")
        let rmddir = substitute(rmddir, '\\', '/', 'g')
    endif
    let params = input('Knitr parameters: ')
    let suffix = substitute(params, '\w\+=', '', 'g')
    let filename = expand('%:t:r') . '-' . suffix
    let filename = substitute(substitute(filename, '\W\+', '-', 'g'), '-$', '', '')
    let rcmd = 'nvim.interlace.rmd("' . expand('%:t') . '", rmddir = "' . rmddir . '", output_file = "' . filename . '", params = list(' . params . ')'
    if a:t != "default"
        let rcmd = rcmd . ', outform = "' . a:t . '"'
    endif
    let rcmd = rcmd . ', envir = ' . g:R_rmd_environment . ')'
    call g:SendCmdToR(rcmd)
endfunction


" Save folds.
"augroup RmdFiletype
    "autocmd!
    "autocmd BufWinEnter     <buffer>    :loadview
"augroup END

"augroup RmdAutoMkview
    "autocmd!
    "autocmd BufWinLeave     <buffer>    :if &foldenable | mkview | endif
    "autocmd BufWritePost    <buffer>    :if &foldenable | mkview | endif
"augroup END
