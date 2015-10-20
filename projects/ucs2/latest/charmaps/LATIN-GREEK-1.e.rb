; LATIN-GREEK-1 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/LATIN-GREEK-1
any [
#{21} (insert tail result #{039E}) | 
#{23} (insert tail result #{0393}) | 
#{24} (insert tail result #{00A4}) | 
#{3F} (insert tail result #{03A0}) | 
#{40} (insert tail result #{0394}) | 
#{5B} (insert tail result #{03A9}) | 
#{5C} (insert tail result #{0398}) | 
#{5D} (insert tail result #{03A6}) | 
#{5E} (insert tail result #{039B}) | 
#{5F} (insert tail result #{03A3}) | 
#{7E} (insert tail result #{203E}) | 
copy c 1 skip (insert tail result join #{00} c)
]