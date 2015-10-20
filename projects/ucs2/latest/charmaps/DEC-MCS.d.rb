; DEC-MCS UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/DEC-MCS
any [
#{00A4} (insert tail result #{A8}) | 
#{0152} (insert tail result #{D7}) | 
#{0178} (insert tail result #{DD}) | 
#{0153} (insert tail result #{F7}) | 
#{00FF} (insert tail result #{FD}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]