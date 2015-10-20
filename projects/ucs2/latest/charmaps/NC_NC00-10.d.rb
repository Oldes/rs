; NC_NC00-10 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/NC_NC00-10
any [
#{00A4} (insert tail result #{24}) | 
#{00A1} (insert tail result #{5B}) | 
#{00D1} (insert tail result #{5C}) | 
#{00BF} (insert tail result #{5E}) | 
#{00B4} (insert tail result #{7B}) | 
#{00F1} (insert tail result #{7C}) | 
#{005B} (insert tail result #{7D}) | 
#{00A8} (insert tail result #{7E}) | 
#{005B} (insert tail result #{7D}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]