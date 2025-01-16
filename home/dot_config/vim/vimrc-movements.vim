vim9script

# Easier movement keys for Dvorak:
# - left: <s> alone is pretty useless (use <c>)
# - up and down: in the left home row

noremap k <C-r>
noremap j u
map l <Nop>

var keys = [
    ['o', 'k'],  # up
    ['u', 'j'],  # down
    ['h', 'h'],  # left
    ['s', 'l']   # right
]

def RemapKey(from_key: string, to_key: string, template: string)
    var remap_command = printf(template, from_key, to_key)
    execute remap_command
enddef


for key_pair in keys
    var from_key = key_pair[0]
    var to_key = key_pair[1]

    call RemapKey(from_key, to_key, 'noremap %s %s')
    call RemapKey(from_key, to_key, 'inoremap <C-%s> %s')
    call RemapKey(from_key, to_key, 'noremap <C-%s> <C-W>%s')
    call RemapKey(from_key, to_key, 'tnoremap <C-W><C-%s> <C-W><C-%s>')
    call RemapKey(from_key->toupper(), to_key->toupper(), 'noremap <C-W>%s <C-W>%s')
endfor

# Wrap mode hack.
noremap o gk
noremap u gj
