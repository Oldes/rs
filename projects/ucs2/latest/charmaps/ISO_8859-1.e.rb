; ISO_8859-1 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO_8859-1
; created: 13-Oct-2003/10:22:23+2:00
any [
copy c 1 skip (insert tail result join #{00} c)
]