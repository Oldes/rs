; JIS_C6229-1984-A UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/JIS_C6229-1984-A
any [
#{00A3} (insert tail result #{23}) | 
#{2440} (insert tail result #{3C}) | 
#{2441} (insert tail result #{3E}) | 
#{00A5} (insert tail result #{5C}) | 
#{2442} (insert tail result #{5D}) | 
#{2443} (insert tail result #{7C}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]