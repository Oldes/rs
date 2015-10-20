; ISO-8859-9 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ISO-8859-9
any [
#{011E} (insert tail result #{D0}) | 
#{0130} (insert tail result #{DD}) | 
#{015E} (insert tail result #{DE}) | 
#{011F} (insert tail result #{F0}) | 
#{0131} (insert tail result #{FD}) | 
#{015F} (insert tail result #{FE}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]