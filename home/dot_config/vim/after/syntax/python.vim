syn region pythonSingleQuoteString
      \ start="[uU]\?'" skip="\\'" end="'"
      \ contains=pythonEscape,@Spell
syn region pythonRawSingleQuoteString
      \ start="[uU]\?[rR]'" skip="\\'" end="'"
      \ contains=@Spell
" matchgroup=pythonQuotes
"
" Repeat code for triple-quoted string from default python.vim to
" undo the customization for it.
syn region pythonString matchgroup=pythonTripleQuotes
      \ start=+[uU]\=\z('''\|"""\)+ end="\z1" keepend
      \ contains=pythonEscape,pythonSpaceError,pythonDoctest,@Spell
syn region pythonRawString matchgroup=pythonTripleQuotes
      \ start=+[uU]\=[rR]\z('''\|"""\)+ end="\z1" keepend
      \ contains=pythonSpaceError,pythonDoctest,@Spell

hi link pythonSingleQuoteString Character
hi link pythonRawSingleQuoteString Character
