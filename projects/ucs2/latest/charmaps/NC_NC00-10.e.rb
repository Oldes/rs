; NC_NC00-10 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/NC_NC00-10
any [
#{24} (insert tail result #{00A4}) | 
#{5B} (insert tail result #{00A1}) | 
#{5C} (insert tail result #{00D1}) | 
#{5E} (insert tail result #{00BF}) | 
#{7B} (insert tail result #{00B4}) | 
#{7C} (insert tail result #{00F1}) | 
#{7D} (insert tail result #{005B}) | 
#{7E} (insert tail result #{00A8}) | 
#{7D} (insert tail result #{005B}) | 
copy c 1 skip (insert tail result join #{00} c)
]