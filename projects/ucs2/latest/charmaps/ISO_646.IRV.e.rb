; ISO_646.IRV UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO_646.IRV
any [
#{24} (insert tail result #{00A4}) | 
#{7E} (insert tail result #{203E}) | 
copy c 1 skip (insert tail result join #{00} c)
]