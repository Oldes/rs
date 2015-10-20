; ISO_2033-1983 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO_2033-1983
any [
#{3A} (insert tail result #{2446}) | 
#{3B} (insert tail result #{2447}) | 
#{3C} (insert tail result #{2448}) | 
#{3D} (insert tail result #{2449}) | 
copy c 1 skip (insert tail result join #{00} c)
]