; DIN_66003 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/DIN_66003
any [
#{00A7} (insert tail result #{40}) | 
#{00C4} (insert tail result #{5B}) | 
#{00D6} (insert tail result #{5C}) | 
#{00DC} (insert tail result #{5D}) | 
#{00E4} (insert tail result #{7B}) | 
#{00F6} (insert tail result #{7C}) | 
#{00FC} (insert tail result #{7D}) | 
#{00DF} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]