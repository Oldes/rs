; SEN_850200_B UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/SEN_850200_B
any [
#{24} (insert tail result #{00A4}) | 
#{5B} (insert tail result #{00C4}) | 
#{5C} (insert tail result #{00D6}) | 
#{5D} (insert tail result #{00C5}) | 
#{7B} (insert tail result #{00E4}) | 
#{7C} (insert tail result #{00F6}) | 
#{7D} (insert tail result #{00E5}) | 
#{7E} (insert tail result #{203E}) | 
copy c 1 skip (insert tail result join #{00} c)
]