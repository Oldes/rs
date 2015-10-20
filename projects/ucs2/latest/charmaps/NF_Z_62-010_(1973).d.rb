; NF_Z_62-010_(1973) UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/NF_Z_62-010_(1973)
any [
#{00A3} (insert tail result #{23}) | 
#{00E0} (insert tail result #{40}) | 
#{00B0} (insert tail result #{5B}) | 
#{00E7} (insert tail result #{5C}) | 
#{00A7} (insert tail result #{5D}) | 
#{00E9} (insert tail result #{7B}) | 
#{00F9} (insert tail result #{7C}) | 
#{00E8} (insert tail result #{7D}) | 
#{00A8} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]