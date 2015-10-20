; BS_4730 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/BS_4730
any [
#{00A3} (insert tail result #{23}) | 
#{203E} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]