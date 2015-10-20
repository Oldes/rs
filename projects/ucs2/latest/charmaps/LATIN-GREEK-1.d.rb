; LATIN-GREEK-1 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/LATIN-GREEK-1
any [
#{039E} (insert tail result #{21}) | 
#{0393} (insert tail result #{23}) | 
#{00A4} (insert tail result #{24}) | 
#{03A0} (insert tail result #{3F}) | 
#{0394} (insert tail result #{40}) | 
#{03A9} (insert tail result #{5B}) | 
#{0398} (insert tail result #{5C}) | 
#{03A6} (insert tail result #{5D}) | 
#{039B} (insert tail result #{5E}) | 
#{03A3} (insert tail result #{5F}) | 
#{203E} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]