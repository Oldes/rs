; JIS_C6229-1984-B UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/JIS_C6229-1984-B
any [
#{2329} (insert tail result #{5B}) | 
#{00A5} (insert tail result #{5C}) | 
#{232A} (insert tail result #{5D}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]