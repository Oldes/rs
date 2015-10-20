; JIS_C6220-1969-RO UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/JIS_C6220-1969-RO
any [
#{5C} (insert tail result #{00A5}) | 
#{7E} (insert tail result #{203E}) | 
copy c 1 skip (insert tail result join #{00} c)
]