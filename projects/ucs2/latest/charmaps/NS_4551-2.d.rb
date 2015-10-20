; NS_4551-2 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/NS_4551-2
any [
#{00A7} (insert tail result #{23}) | 
#{00C6} (insert tail result #{5B}) | 
#{00D8} (insert tail result #{5C}) | 
#{00C5} (insert tail result #{5D}) | 
#{00E6} (insert tail result #{7B}) | 
#{00F8} (insert tail result #{7C}) | 
#{00E5} (insert tail result #{7D}) | 
#{007C} (insert tail result #{7E}) | 
#{007C} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]