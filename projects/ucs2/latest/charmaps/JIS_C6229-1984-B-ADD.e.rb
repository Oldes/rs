; JIS_C6229-1984-B-ADD UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/JIS_C6229-1984-B-ADD
any [
#{23} (insert tail result #{00A3}) | 
#{24} (insert tail result #{00A4}) | 
#{25} (insert tail result #{005C}) | 
#{27} (insert tail result #{00A7}) | 
#{25} (insert tail result #{005C}) | 
#{25} (insert tail result #{005C}) | 
copy c 1 skip (insert tail result join #{00} c)
]