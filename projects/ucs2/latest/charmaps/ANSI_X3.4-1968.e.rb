; ANSI_X3.4-1968 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ANSI_X3.4-1968
any [
copy c 1 skip (insert tail result join #{00} c)
]