; T.61-7BIT UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/T.61-7BIT
any [
#{00A4} (insert tail result #{24}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]