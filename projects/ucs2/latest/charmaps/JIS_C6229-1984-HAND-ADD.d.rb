; JIS_C6229-1984-HAND-ADD UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/JIS_C6229-1984-HAND-ADD
any [
#{005C} (insert tail result #{25}) | 
#{005C} (insert tail result #{25}) | 
#{005C} (insert tail result #{25}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]