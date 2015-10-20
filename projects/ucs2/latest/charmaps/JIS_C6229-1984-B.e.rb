; JIS_C6229-1984-B UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/JIS_C6229-1984-B
any [
#{5B} (insert tail result #{2329}) | 
#{5C} (insert tail result #{00A5}) | 
#{5D} (insert tail result #{232A}) | 
copy c 1 skip (insert tail result join #{00} c)
]