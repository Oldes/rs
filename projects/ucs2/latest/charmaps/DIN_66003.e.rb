; DIN_66003 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/DIN_66003
any [
#{40} (insert tail result #{00A7}) | 
#{5B} (insert tail result #{00C4}) | 
#{5C} (insert tail result #{00D6}) | 
#{5D} (insert tail result #{00DC}) | 
#{7B} (insert tail result #{00E4}) | 
#{7C} (insert tail result #{00F6}) | 
#{7D} (insert tail result #{00FC}) | 
#{7E} (insert tail result #{00DF}) | 
copy c 1 skip (insert tail result join #{00} c)
]