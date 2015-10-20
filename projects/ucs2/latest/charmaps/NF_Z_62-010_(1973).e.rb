; NF_Z_62-010_(1973) UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/NF_Z_62-010_(1973)
any [
#{23} (insert tail result #{00A3}) | 
#{40} (insert tail result #{00E0}) | 
#{5B} (insert tail result #{00B0}) | 
#{5C} (insert tail result #{00E7}) | 
#{5D} (insert tail result #{00A7}) | 
#{7B} (insert tail result #{00E9}) | 
#{7C} (insert tail result #{00F9}) | 
#{7D} (insert tail result #{00E8}) | 
#{7E} (insert tail result #{00A8}) | 
copy c 1 skip (insert tail result join #{00} c)
]