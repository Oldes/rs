; T.61-7BIT UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/T.61-7BIT
any [
#{24} (insert tail result #{00A4}) | 
copy c 1 skip (insert tail result join #{00} c)
]