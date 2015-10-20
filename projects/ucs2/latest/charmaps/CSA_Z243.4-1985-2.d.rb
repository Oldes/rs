; CSA_Z243.4-1985-2 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/CSA_Z243.4-1985-2
any [
#{00E0} (insert tail result #{40}) | 
#{00E2} (insert tail result #{5B}) | 
#{00E7} (insert tail result #{5C}) | 
#{00EA} (insert tail result #{5D}) | 
#{00C9} (insert tail result #{5E}) | 
#{00F4} (insert tail result #{60}) | 
#{00E9} (insert tail result #{7B}) | 
#{00F9} (insert tail result #{7C}) | 
#{00E8} (insert tail result #{7D}) | 
#{00FB} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]