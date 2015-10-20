; IBM904 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/IBM904
any [
#{00A2} (insert tail result #{80}) | 
#{00AC} (insert tail result #{FD}) | 
#{00A6} (insert tail result #{FE}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]