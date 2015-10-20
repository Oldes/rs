; IBM904 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/IBM904
any [
#{80} (insert tail result #{00A2}) | 
#{FD} (insert tail result #{00AC}) | 
#{FE} (insert tail result #{00A6}) | 
copy c 1 skip (insert tail result join #{00} c)
]