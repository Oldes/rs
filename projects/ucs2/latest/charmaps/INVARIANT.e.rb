; INVARIANT UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/INVARIANT
any [
copy c 1 skip (insert tail result join #{00} c)
]