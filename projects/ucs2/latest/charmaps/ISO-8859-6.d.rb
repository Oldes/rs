; ISO-8859-6 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ISO-8859-6
any [
#{060C} (insert tail result #{AC}) | 
#{061B} (insert tail result #{BB}) | 
#{061F} (insert tail result #{BF}) | 
#{0621} (insert tail result #{C1}) | 
#{0622} (insert tail result #{C2}) | 
#{0623} (insert tail result #{C3}) | 
#{0624} (insert tail result #{C4}) | 
#{0625} (insert tail result #{C5}) | 
#{0626} (insert tail result #{C6}) | 
#{0627} (insert tail result #{C7}) | 
#{0628} (insert tail result #{C8}) | 
#{0629} (insert tail result #{C9}) | 
#{062A} (insert tail result #{CA}) | 
#{062B} (insert tail result #{CB}) | 
#{062C} (insert tail result #{CC}) | 
#{062D} (insert tail result #{CD}) | 
#{062E} (insert tail result #{CE}) | 
#{062F} (insert tail result #{CF}) | 
#{0630} (insert tail result #{D0}) | 
#{0631} (insert tail result #{D1}) | 
#{0632} (insert tail result #{D2}) | 
#{0633} (insert tail result #{D3}) | 
#{0634} (insert tail result #{D4}) | 
#{0635} (insert tail result #{D5}) | 
#{0636} (insert tail result #{D6}) | 
#{0637} (insert tail result #{D7}) | 
#{0638} (insert tail result #{D8}) | 
#{0639} (insert tail result #{D9}) | 
#{063A} (insert tail result #{DA}) | 
#{0640} (insert tail result #{E0}) | 
#{0641} (insert tail result #{E1}) | 
#{0642} (insert tail result #{E2}) | 
#{0643} (insert tail result #{E3}) | 
#{0644} (insert tail result #{E4}) | 
#{0645} (insert tail result #{E5}) | 
#{0646} (insert tail result #{E6}) | 
#{0647} (insert tail result #{E7}) | 
#{0648} (insert tail result #{E8}) | 
#{0649} (insert tail result #{E9}) | 
#{064A} (insert tail result #{EA}) | 
#{064B} (insert tail result #{EB}) | 
#{064C} (insert tail result #{EC}) | 
#{064D} (insert tail result #{ED}) | 
#{064E} (insert tail result #{EE}) | 
#{064F} (insert tail result #{EF}) | 
#{0650} (insert tail result #{F0}) | 
#{0651} (insert tail result #{F1}) | 
#{0652} (insert tail result #{F2}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]