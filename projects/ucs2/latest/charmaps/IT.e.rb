; IT UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/IT
any [
#{23} (insert tail result #{00A3}) | 
#{40} (insert tail result #{00A7}) | 
#{5B} (insert tail result #{00B0}) | 
#{5C} (insert tail result #{00E7}) | 
#{5D} (insert tail result #{00E9}) | 
#{60} (insert tail result #{00F9}) | 
#{7B} (insert tail result #{00E0}) | 
#{7C} (insert tail result #{00F2}) | 
#{7D} (insert tail result #{00E8}) | 
#{7E} (insert tail result #{00EC}) | 
copy c 1 skip (insert tail result join #{00} c)
]