; INVARIANT UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/INVARIANT
any [
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]