; ES UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ES
any [
#{00A3} (insert tail result #{23}) | 
#{00A7} (insert tail result #{40}) | 
#{00A1} (insert tail result #{5B}) | 
#{00D1} (insert tail result #{5C}) | 
#{00BF} (insert tail result #{5D}) | 
#{00B0} (insert tail result #{7B}) | 
#{00F1} (insert tail result #{7C}) | 
#{00E7} (insert tail result #{7D}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]