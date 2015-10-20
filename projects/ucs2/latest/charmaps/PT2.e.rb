; PT2 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/PT2
any [
#{40} (insert tail result #{00B4}) | 
#{5B} (insert tail result #{00C3}) | 
#{5C} (insert tail result #{00C7}) | 
#{5D} (insert tail result #{00D5}) | 
#{7B} (insert tail result #{00E3}) | 
#{7C} (insert tail result #{00E7}) | 
#{7D} (insert tail result #{00F5}) | 
copy c 1 skip (insert tail result join #{00} c)
]