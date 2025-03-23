" Vim filetype plugin file
" Language: R

if exists('b:did_user_ftplugin')
    finish
endif
let b:did_user_ftplugin = 1

" for RCustomStart
"let $R_LIBS_USER = '~/.local/lib/R-site-library'

" assignment and pipe operators
iabbrev  <buffer> -- <-
inoremap <buffer> .. \|>
inoremap <buffer> ... ...

" extra operators
iabbrev <buffer> >% %>%
iabbrev <buffer> >T %T>%
iabbrev <buffer> >$ %$%
iabbrev <buffer> inn %in%
iabbrev <buffer> nin %nin%
iabbrev <buffer> like %like%

" logicals
iabbrev <buffer> T TRUE
iabbrev <buffer> F FALSE

" vim-R plugin
let R_args = ['-q', '--no-restore-data']  " the same as in .alias.sh
let R_assign = 0
let R_debug = 0
let R_nvim_wd = 1

" window sizes
let R_help_w = 88
let R_min_editor_width = 80
let R_rconsole_height = 17
let R_rconsole_width = &columns - (R_min_editor_width + &number*&numberwidth + 2)
set winfixwidth

" Don't overwrite my custom mappings (\o and \u).
let R_disable_cmds = [
\   'RDebug',
\   'RUndebug',
\   '(RDSendLineAndInsertOutput)',
\   ]

" Doesn't work if disabled above.
nmap <buffer> <Leader>rF <Plug>RCustomStart

" Custom vim-R key-bindings.
nmap <buffer><silent>   <Leader>n   :call SendCmdToR('dev.new()')<CR>
nmap <buffer><silent>   <Leader>RR  :call SendCmdToR('cl()')<CR>

" For Snakemake?
command! -buffer RStart let b:oldft=&ft | set ft=r | exe 'set ft='.oldft | let b:IsInRCode = function('DefaultIsInRCode') | normal <LocalLeader>rf

" ALE-lintr
" See ?lintr::default_linters and ?lintr::linters
let ale_r_lintr_options = 'with_defaults(
\   closed_curly_linter(allow_single_line=TRUE),
\   commented_code_linter=NULL,
\   cyclocomp_linter(20L),
\   infix_spaces_linter=NULL,
\   line_length_linter(120L),
\   object_length_linter(20L),
\   object_name_linter=NULL,
\   object_usage_linter=NULL,
\   open_curly_linter(allow_single_line=TRUE),
\   semicolon_terminator_linter(semicolon="trailing"),
\   spaces_inside_linter=NULL,
\   single_quotes_linter=NULL,
\   missing_argument_linter,
\   nonportable_path_linter,
\   sprintf_linter,
\   todo_comment_linter,
\   unneeded_concatenation_linter,
\   undesirable_function_linter(with_defaults(attach=NULL, detach=NULL, library=NULL, options=NULL, par=NULL, source=NULL, default=default_undesirable_functions)),
\   undesirable_operator_linter(op=c(default_undesirable_operators, list("^"="use `**`")))
\)'
