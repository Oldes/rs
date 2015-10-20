; NS_4551-1 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/NS_4551-1
any [
#{5B} (insert tail result #{00C6}) | 
#{5C} (insert tail result #{00D8}) | 
#{5D} (insert tail result #{00C5}) | 
#{7B} (insert tail result #{00E6}) | 
#{7C} (insert tail result #{00F8}) | 
#{7D} (insert tail result #{00E5}) | 
#{7E} (insert tail result #{203E}) | 
copy c 1 skip (insert tail result join #{00} c)
]