; ES2 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ES2
any [
#{40} (insert tail result #{2022}) | 
#{5B} (insert tail result #{00A1}) | 
#{5C} (insert tail result #{00D1}) | 
#{5D} (insert tail result #{00C7}) | 
#{5E} (insert tail result #{00BF}) | 
#{7B} (insert tail result #{00B4}) | 
#{7C} (insert tail result #{00F1}) | 
#{7D} (insert tail result #{00E7}) | 
#{7E} (insert tail result #{00A8}) | 
copy c 1 skip (insert tail result join #{00} c)
]