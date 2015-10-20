; ISO_5427-EXT UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ISO_5427-EXT
any [
#{0491} (insert tail result #{40}) | 
#{0452} (insert tail result #{41}) | 
#{0453} (insert tail result #{42}) | 
#{0454} (insert tail result #{43}) | 
#{0451} (insert tail result #{44}) | 
#{0456} (insert tail result #{46}) | 
#{0457} (insert tail result #{47}) | 
#{0458} (insert tail result #{48}) | 
#{0459} (insert tail result #{49}) | 
#{045A} (insert tail result #{4A}) | 
#{045B} (insert tail result #{4B}) | 
#{045C} (insert tail result #{4C}) | 
#{045E} (insert tail result #{4D}) | 
#{045F} (insert tail result #{4E}) | 
#{0463} (insert tail result #{50}) | 
#{0473} (insert tail result #{51}) | 
#{0475} (insert tail result #{52}) | 
#{046B} (insert tail result #{53}) | 
#{0490} (insert tail result #{60}) | 
#{0402} (insert tail result #{61}) | 
#{0403} (insert tail result #{62}) | 
#{0404} (insert tail result #{63}) | 
#{0401} (insert tail result #{64}) | 
#{0405} (insert tail result #{65}) | 
#{0406} (insert tail result #{66}) | 
#{0407} (insert tail result #{67}) | 
#{0408} (insert tail result #{68}) | 
#{0409} (insert tail result #{69}) | 
#{040A} (insert tail result #{6A}) | 
#{040B} (insert tail result #{6B}) | 
#{040C} (insert tail result #{6C}) | 
#{040E} (insert tail result #{6D}) | 
#{040F} (insert tail result #{6E}) | 
#{042A} (insert tail result #{6F}) | 
#{0462} (insert tail result #{70}) | 
#{0472} (insert tail result #{71}) | 
#{0474} (insert tail result #{72}) | 
#{046A} (insert tail result #{73}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]