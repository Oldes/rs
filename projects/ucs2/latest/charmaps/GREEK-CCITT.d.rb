; GREEK-CCITT UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/GREEK-CCITT
any [
#{00A4} (insert tail result #{24}) | 
#{0391} (insert tail result #{41}) | 
#{0392} (insert tail result #{42}) | 
#{0393} (insert tail result #{43}) | 
#{0394} (insert tail result #{44}) | 
#{0395} (insert tail result #{45}) | 
#{0396} (insert tail result #{46}) | 
#{0397} (insert tail result #{47}) | 
#{0398} (insert tail result #{48}) | 
#{0399} (insert tail result #{49}) | 
#{039A} (insert tail result #{4A}) | 
#{039B} (insert tail result #{4B}) | 
#{039C} (insert tail result #{4C}) | 
#{039D} (insert tail result #{4D}) | 
#{039E} (insert tail result #{4E}) | 
#{039F} (insert tail result #{4F}) | 
#{03A0} (insert tail result #{50}) | 
#{03A1} (insert tail result #{51}) | 
#{03A3} (insert tail result #{53}) | 
#{03A4} (insert tail result #{54}) | 
#{03A5} (insert tail result #{55}) | 
#{03A6} (insert tail result #{56}) | 
#{03A7} (insert tail result #{57}) | 
#{03A8} (insert tail result #{58}) | 
#{03A9} (insert tail result #{59}) | 
#{03B1} (insert tail result #{61}) | 
#{03B2} (insert tail result #{62}) | 
#{03B3} (insert tail result #{63}) | 
#{03B4} (insert tail result #{64}) | 
#{03B5} (insert tail result #{65}) | 
#{03B6} (insert tail result #{66}) | 
#{03B7} (insert tail result #{67}) | 
#{03B8} (insert tail result #{68}) | 
#{03B9} (insert tail result #{69}) | 
#{03BA} (insert tail result #{6A}) | 
#{03BB} (insert tail result #{6B}) | 
#{03BC} (insert tail result #{6C}) | 
#{03BD} (insert tail result #{6D}) | 
#{03BE} (insert tail result #{6E}) | 
#{03BF} (insert tail result #{6F}) | 
#{03C0} (insert tail result #{70}) | 
#{03C1} (insert tail result #{71}) | 
#{03C2} (insert tail result #{72}) | 
#{03C3} (insert tail result #{73}) | 
#{03C4} (insert tail result #{74}) | 
#{03C5} (insert tail result #{75}) | 
#{03C6} (insert tail result #{76}) | 
#{03C7} (insert tail result #{77}) | 
#{03C8} (insert tail result #{78}) | 
#{03C9} (insert tail result #{79}) | 
#{00AF} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]