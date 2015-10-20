; JIS_C6229-1984-A UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/JIS_C6229-1984-A
any [
#{23} (insert tail result #{00A3}) | 
#{3C} (insert tail result #{2440}) | 
#{3E} (insert tail result #{2441}) | 
#{5C} (insert tail result #{00A5}) | 
#{5D} (insert tail result #{2442}) | 
#{7C} (insert tail result #{2443}) | 
copy c 1 skip (insert tail result join #{00} c)
]