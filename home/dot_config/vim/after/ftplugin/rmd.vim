" Nvim-R
unmap <buffer> <Leader>rc
unmap <buffer> <Leader>cd

" from github.com/vim-pandoc/vim-rmarkdown
PandocHighlight r
" recognizes embedded R differently than regular pandoc
exe 'syn region pandocRChunk '. 
            \'start=/\(```\s*{\s*r.*\n\)\@<=\_^/ ' .
            \'end=/\_$\n\(\(\s\{4,}\)\=\(`\{3,}`*\|\~\{3,}\~*\)\_$\n\_$\)\@=/ '. 
            \'contained containedin=pandocDelimitedCodeblock contains=@R'

syn region pandocInlineR matchgroup=Operator start=/`r\s/ end=/`/ contains=@R concealends

PandocHighlight python
" recognizes embedded R differently than regular pandoc
exe 'syn region pandocPythonChunk '. 
            \'start=/\(```\s*{\s*python.*\n\)\@<=\_^/ ' .
            \'end=/\_$\n\(\(\s\{4,}\)\=\(`\{3,}`*\|\~\{3,}\~*\)\_$\n\_$\)\@=/ '. 
            \'contained containedin=pandocDelimitedCodeblock contains=@python'

syn region pandocInlinePython matchgroup=Operator start=/`python\s/ end=/`/ contains=@Python concealends
