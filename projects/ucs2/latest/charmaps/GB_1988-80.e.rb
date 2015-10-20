; GB_1988-80 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/GB_1988-80
any [
#{24} (insert tail result #{00A5}) | 
#{7E} (insert tail result #{203E}) | 
copy c 1 skip (insert tail result join #{00} c)
]