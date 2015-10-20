; JIS_C6229-1984-B-ADD UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/JIS_C6229-1984-B-ADD
any [
#{00A3} (insert tail result #{23}) | 
#{00A4} (insert tail result #{24}) | 
#{005C} (insert tail result #{25}) | 
#{00A7} (insert tail result #{27}) | 
#{005C} (insert tail result #{25}) | 
#{005C} (insert tail result #{25}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]