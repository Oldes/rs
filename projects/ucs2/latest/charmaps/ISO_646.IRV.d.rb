; ISO_646.IRV UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ISO_646.IRV
any [
#{00A4} (insert tail result #{24}) | 
#{203E} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]