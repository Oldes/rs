; SEN_850200_B UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/SEN_850200_B
any [
#{00A4} (insert tail result #{24}) | 
#{00C4} (insert tail result #{5B}) | 
#{00D6} (insert tail result #{5C}) | 
#{00C5} (insert tail result #{5D}) | 
#{00E4} (insert tail result #{7B}) | 
#{00F6} (insert tail result #{7C}) | 
#{00E5} (insert tail result #{7D}) | 
#{203E} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]