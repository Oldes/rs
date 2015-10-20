; BS_VIEWDATA UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/BS_VIEWDATA
any [
#{23} (insert tail result #{00A3}) | 
#{5B} (insert tail result #{2190}) | 
#{5C} (insert tail result #{00BD}) | 
#{5D} (insert tail result #{2192}) | 
#{5E} (insert tail result #{2191}) | 
#{5F} (insert tail result #{25A1}) | 
#{7B} (insert tail result #{00BC}) | 
#{7C} (insert tail result #{2225}) | 
#{7D} (insert tail result #{00BE}) | 
#{7E} (insert tail result #{00F7}) | 
copy c 1 skip (insert tail result join #{00} c)
]