; BS_VIEWDATA UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/BS_VIEWDATA
any [
#{00A3} (insert tail result #{23}) | 
#{2190} (insert tail result #{5B}) | 
#{00BD} (insert tail result #{5C}) | 
#{2192} (insert tail result #{5D}) | 
#{2191} (insert tail result #{5E}) | 
#{25A1} (insert tail result #{5F}) | 
#{00BC} (insert tail result #{7B}) | 
#{2225} (insert tail result #{7C}) | 
#{00BE} (insert tail result #{7D}) | 
#{00F7} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]