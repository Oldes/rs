; ISO-8859-1 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO-8859-1
any [
copy c 1 skip (insert tail result join #{00} c)
]