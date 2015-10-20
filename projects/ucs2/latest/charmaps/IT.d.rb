; IT UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/IT
any [
#{00A3} (insert tail result #{23}) | 
#{00A7} (insert tail result #{40}) | 
#{00B0} (insert tail result #{5B}) | 
#{00E7} (insert tail result #{5C}) | 
#{00E9} (insert tail result #{5D}) | 
#{00F9} (insert tail result #{60}) | 
#{00E0} (insert tail result #{7B}) | 
#{00F2} (insert tail result #{7C}) | 
#{00E8} (insert tail result #{7D}) | 
#{00EC} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]