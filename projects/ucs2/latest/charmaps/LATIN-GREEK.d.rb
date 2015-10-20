; LATIN-GREEK UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/LATIN-GREEK
any [
#{00A3} (insert tail result #{23}) | 
#{0391} (insert tail result #{61}) | 
#{0392} (insert tail result #{62}) | 
#{03A8} (insert tail result #{63}) | 
#{0394} (insert tail result #{64}) | 
#{0395} (insert tail result #{65}) | 
#{03A6} (insert tail result #{66}) | 
#{0393} (insert tail result #{67}) | 
#{0397} (insert tail result #{68}) | 
#{0399} (insert tail result #{69}) | 
#{039E} (insert tail result #{6A}) | 
#{039A} (insert tail result #{6B}) | 
#{039B} (insert tail result #{6C}) | 
#{039C} (insert tail result #{6D}) | 
#{039D} (insert tail result #{6E}) | 
#{039F} (insert tail result #{6F}) | 
#{03A0} (insert tail result #{70}) | 
#{03A1} (insert tail result #{72}) | 
#{03A3} (insert tail result #{73}) | 
#{03A4} (insert tail result #{74}) | 
#{0398} (insert tail result #{75}) | 
#{03A9} (insert tail result #{76}) | 
#{00B7} (insert tail result #{77}) | 
#{03A7} (insert tail result #{78}) | 
#{03A5} (insert tail result #{79}) | 
#{0396} (insert tail result #{7A}) | 
#{00A8} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]