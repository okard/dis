" vim dis syntax file
" file ending: *.dis
"
"
"

if exists("b:current_syntax")
    finish
endif

" Keywords & Types
syn keyword disType             bool void byte ubyte short ushort int uint long ulong float double char string
syn keyword disDeclaration      package class def var val type
syn keyword disExpression       if switch case 
syn keyword disBoolean          true false

hi def link disType             Type
hi def link disDeclaration      Keyword
hi def link disExpression       Keyword
hi def link disBoolean          Boolean

" Comments
syn region  disComment           start="/\*" end="\*/"
syn region  disComment           start="//" end="$"

hi def link disComment           Comment


let b:current_syntax = "dis"
