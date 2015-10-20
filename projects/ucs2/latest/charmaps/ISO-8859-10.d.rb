; ISO-8859-10 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ISO-8859-10
any [
#{0104} (insert tail result #{A1}) | 
#{0112} (insert tail result #{A2}) | 
#{0122} (insert tail result #{A3}) | 
#{012A} (insert tail result #{A4}) | 
#{0128} (insert tail result #{A5}) | 
#{0136} (insert tail result #{A6}) | 
#{013B} (insert tail result #{A8}) | 
#{0110} (insert tail result #{A9}) | 
#{0160} (insert tail result #{AA}) | 
#{0166} (insert tail result #{AB}) | 
#{017D} (insert tail result #{AC}) | 
#{016A} (insert tail result #{AE}) | 
#{014A} (insert tail result #{AF}) | 
#{0105} (insert tail result #{B1}) | 
#{0113} (insert tail result #{B2}) | 
#{0123} (insert tail result #{B3}) | 
#{012B} (insert tail result #{B4}) | 
#{0129} (insert tail result #{B5}) | 
#{0137} (insert tail result #{B6}) | 
#{013C} (insert tail result #{B8}) | 
#{0111} (insert tail result #{B9}) | 
#{0161} (insert tail result #{BA}) | 
#{0167} (insert tail result #{BB}) | 
#{017E} (insert tail result #{BC}) | 
#{2014} (insert tail result #{BD}) | 
#{016B} (insert tail result #{BE}) | 
#{014B} (insert tail result #{BF}) | 
#{0100} (insert tail result #{C0}) | 
#{012E} (insert tail result #{C7}) | 
#{010C} (insert tail result #{C8}) | 
#{0118} (insert tail result #{CA}) | 
#{0116} (insert tail result #{CC}) | 
#{0145} (insert tail result #{D1}) | 
#{014C} (insert tail result #{D2}) | 
#{0168} (insert tail result #{D7}) | 
#{0172} (insert tail result #{D9}) | 
#{0101} (insert tail result #{E0}) | 
#{012F} (insert tail result #{E7}) | 
#{010D} (insert tail result #{E8}) | 
#{0119} (insert tail result #{EA}) | 
#{0117} (insert tail result #{EC}) | 
#{0146} (insert tail result #{F1}) | 
#{014D} (insert tail result #{F2}) | 
#{0169} (insert tail result #{F7}) | 
#{0173} (insert tail result #{F9}) | 
#{0138} (insert tail result #{FF}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]