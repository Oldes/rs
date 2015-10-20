; JIS_C6229-1984-HAND-ADD UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/JIS_C6229-1984-HAND-ADD
any [
#{25} (insert tail result #{005C}) | 
#{25} (insert tail result #{005C}) | 
#{25} (insert tail result #{005C}) | 
copy c 1 skip (insert tail result join #{00} c)
]