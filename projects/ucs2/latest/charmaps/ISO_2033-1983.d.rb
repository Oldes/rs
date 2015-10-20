; ISO_2033-1983 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ISO_2033-1983
any [
#{2446} (insert tail result #{3A}) | 
#{2447} (insert tail result #{3B}) | 
#{2448} (insert tail result #{3C}) | 
#{2449} (insert tail result #{3D}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]