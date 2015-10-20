; PT2 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/PT2
any [
#{00B4} (insert tail result #{40}) | 
#{00C3} (insert tail result #{5B}) | 
#{00C7} (insert tail result #{5C}) | 
#{00D5} (insert tail result #{5D}) | 
#{00E3} (insert tail result #{7B}) | 
#{00E7} (insert tail result #{7C}) | 
#{00F5} (insert tail result #{7D}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]