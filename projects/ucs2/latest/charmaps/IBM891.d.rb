; IBM891 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/IBM891
any [
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]