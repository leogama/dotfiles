call SyntaxRange#Include("  shell: '", "'$", 'sh', 'Identifier')
call SyntaxRange#Include("  shell: '''", "'''$", 'sh', 'Identifier')
call SyntaxRange#Include("  shell('", "')$", 'sh', 'Identifier')
call SyntaxRange#Include("  shell('''", "''')$", 'sh', 'Identifier')
call SyntaxRange#Include("R('''", "''')$", 'r', 'Identifier')
