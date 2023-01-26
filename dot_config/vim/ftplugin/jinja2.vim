" Vim filetype plugin file
" Language: Jinja2 template (HTML5)

if exists('b:did_user_ftplugin')
    finish
endif
let b:did_user_ftplugin = 1

" Behaves just like HTML
runtime! ftplugin/html.vim ftplugin/html_*.vim ftplugin/html/*.vim
