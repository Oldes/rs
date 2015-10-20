; INIS-8 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/INIS-8
any [
#{03B1} (insert tail result #{3A}) | 
#{03B3} (insert tail result #{3C}) | 
#{03B4} (insert tail result #{3D}) | 
#{039E} (insert tail result #{3E}) | 
#{2192} (insert tail result #{5E}) | 
#{222B} (insert tail result #{5F}) | 
#{2070} (insert tail result #{60}) | 
#{00B9} (insert tail result #{61}) | 
#{00B2} (insert tail result #{62}) | 
#{00B3} (insert tail result #{63}) | 
#{2074} (insert tail result #{64}) | 
#{2075} (insert tail result #{65}) | 
#{2076} (insert tail result #{66}) | 
#{2077} (insert tail result #{67}) | 
#{2078} (insert tail result #{68}) | 
#{2079} (insert tail result #{69}) | 
#{207A} (insert tail result #{6A}) | 
#{207B} (insert tail result #{6B}) | 
#{30EB} (insert tail result #{6C}) | 
#{0394} (insert tail result #{6D}) | 
#{039B} (insert tail result #{6E}) | 
#{03A9} (insert tail result #{6F}) | 
#{2080} (insert tail result #{70}) | 
#{2081} (insert tail result #{71}) | 
#{2082} (insert tail result #{72}) | 
#{2083} (insert tail result #{73}) | 
#{2084} (insert tail result #{74}) | 
#{2085} (insert tail result #{75}) | 
#{2086} (insert tail result #{76}) | 
#{2087} (insert tail result #{77}) | 
#{2088} (insert tail result #{78}) | 
#{2089} (insert tail result #{79}) | 
#{03A3} (insert tail result #{7A}) | 
#{03BC} (insert tail result #{7B}) | 
#{03BD} (insert tail result #{7C}) | 
#{03C9} (insert tail result #{7D}) | 
#{03C0} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]