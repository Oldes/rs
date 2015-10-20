; JIS_C6220-1969-RO UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/JIS_C6220-1969-RO
any [
#{00A5} (insert tail result #{5C}) | 
#{203E} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]