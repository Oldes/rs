; KSC5636 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/KSC5636
any [
#{5C} (insert tail result #{20A9}) | 
copy c 1 skip (insert tail result join #{00} c)
]