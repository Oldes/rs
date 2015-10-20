; MSZ_7795.3 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/MSZ_7795.3
any [
#{00A4} (insert tail result #{24}) | 
#{00C1} (insert tail result #{40}) | 
#{00C9} (insert tail result #{5B}) | 
#{00D6} (insert tail result #{5C}) | 
#{00DC} (insert tail result #{5D}) | 
#{00E1} (insert tail result #{60}) | 
#{00E9} (insert tail result #{7B}) | 
#{00F6} (insert tail result #{7C}) | 
#{00FC} (insert tail result #{7D}) | 
#{02DD} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]