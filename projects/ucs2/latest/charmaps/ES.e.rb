; ES UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ES
any [
#{23} (insert tail result #{00A3}) | 
#{40} (insert tail result #{00A7}) | 
#{5B} (insert tail result #{00A1}) | 
#{5C} (insert tail result #{00D1}) | 
#{5D} (insert tail result #{00BF}) | 
#{7B} (insert tail result #{00B0}) | 
#{7C} (insert tail result #{00F1}) | 
#{7D} (insert tail result #{00E7}) | 
copy c 1 skip (insert tail result join #{00} c)
]