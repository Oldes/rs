; KSC5636 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/KSC5636
any [
#{20A9} (insert tail result #{5C}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]