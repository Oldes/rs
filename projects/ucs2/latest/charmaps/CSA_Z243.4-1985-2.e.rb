; CSA_Z243.4-1985-2 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/CSA_Z243.4-1985-2
any [
#{40} (insert tail result #{00E0}) | 
#{5B} (insert tail result #{00E2}) | 
#{5C} (insert tail result #{00E7}) | 
#{5D} (insert tail result #{00EA}) | 
#{5E} (insert tail result #{00C9}) | 
#{60} (insert tail result #{00F4}) | 
#{7B} (insert tail result #{00E9}) | 
#{7C} (insert tail result #{00F9}) | 
#{7D} (insert tail result #{00E8}) | 
#{7E} (insert tail result #{00FB}) | 
copy c 1 skip (insert tail result join #{00} c)
]