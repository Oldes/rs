; MSZ_7795.3 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/MSZ_7795.3
any [
#{24} (insert tail result #{00A4}) | 
#{40} (insert tail result #{00C1}) | 
#{5B} (insert tail result #{00C9}) | 
#{5C} (insert tail result #{00D6}) | 
#{5D} (insert tail result #{00DC}) | 
#{60} (insert tail result #{00E1}) | 
#{7B} (insert tail result #{00E9}) | 
#{7C} (insert tail result #{00F6}) | 
#{7D} (insert tail result #{00FC}) | 
#{7E} (insert tail result #{02DD}) | 
copy c 1 skip (insert tail result join #{00} c)
]