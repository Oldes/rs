; NS_4551-2 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/NS_4551-2
any [
#{23} (insert tail result #{00A7}) | 
#{5B} (insert tail result #{00C6}) | 
#{5C} (insert tail result #{00D8}) | 
#{5D} (insert tail result #{00C5}) | 
#{7B} (insert tail result #{00E6}) | 
#{7C} (insert tail result #{00F8}) | 
#{7D} (insert tail result #{00E5}) | 
#{7E} (insert tail result #{007C}) | 
#{7E} (insert tail result #{007C}) | 
copy c 1 skip (insert tail result join #{00} c)
]