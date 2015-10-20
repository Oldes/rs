; ASMO_449 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ASMO_449
any [
#{00A4} (insert tail result #{24}) | 
#{060C} (insert tail result #{2C}) | 
#{061B} (insert tail result #{3B}) | 
#{061F} (insert tail result #{3F}) | 
#{0621} (insert tail result #{41}) | 
#{0622} (insert tail result #{42}) | 
#{0623} (insert tail result #{43}) | 
#{0624} (insert tail result #{44}) | 
#{0625} (insert tail result #{45}) | 
#{0626} (insert tail result #{46}) | 
#{0627} (insert tail result #{47}) | 
#{0628} (insert tail result #{48}) | 
#{0629} (insert tail result #{49}) | 
#{062A} (insert tail result #{4A}) | 
#{062B} (insert tail result #{4B}) | 
#{062C} (insert tail result #{4C}) | 
#{062D} (insert tail result #{4D}) | 
#{062E} (insert tail result #{4E}) | 
#{062F} (insert tail result #{4F}) | 
#{0630} (insert tail result #{50}) | 
#{0631} (insert tail result #{51}) | 
#{0632} (insert tail result #{52}) | 
#{0633} (insert tail result #{53}) | 
#{0634} (insert tail result #{54}) | 
#{0635} (insert tail result #{55}) | 
#{0636} (insert tail result #{56}) | 
#{0637} (insert tail result #{57}) | 
#{0638} (insert tail result #{58}) | 
#{0639} (insert tail result #{59}) | 
#{063A} (insert tail result #{5A}) | 
#{0640} (insert tail result #{60}) | 
#{0641} (insert tail result #{61}) | 
#{0642} (insert tail result #{62}) | 
#{0643} (insert tail result #{63}) | 
#{0645} (insert tail result #{65}) | 
#{0646} (insert tail result #{66}) | 
#{0647} (insert tail result #{67}) | 
#{0648} (insert tail result #{68}) | 
#{0649} (insert tail result #{69}) | 
#{064A} (insert tail result #{6A}) | 
#{064B} (insert tail result #{6B}) | 
#{064C} (insert tail result #{6C}) | 
#{064D} (insert tail result #{6D}) | 
#{064E} (insert tail result #{6E}) | 
#{064F} (insert tail result #{6F}) | 
#{0650} (insert tail result #{70}) | 
#{0651} (insert tail result #{71}) | 
#{0652} (insert tail result #{72}) | 
#{203E} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]