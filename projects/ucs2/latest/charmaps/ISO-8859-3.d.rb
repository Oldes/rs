; ISO-8859-3 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ISO-8859-3
any [
#{0126} (insert tail result #{A1}) | 
#{02D8} (insert tail result #{A2}) | 
#{0124} (insert tail result #{A6}) | 
#{0130} (insert tail result #{A9}) | 
#{015E} (insert tail result #{AA}) | 
#{011E} (insert tail result #{AB}) | 
#{0134} (insert tail result #{AC}) | 
#{017B} (insert tail result #{AF}) | 
#{0127} (insert tail result #{B1}) | 
#{0125} (insert tail result #{B6}) | 
#{0131} (insert tail result #{B9}) | 
#{015F} (insert tail result #{BA}) | 
#{011F} (insert tail result #{BB}) | 
#{0135} (insert tail result #{BC}) | 
#{017C} (insert tail result #{BF}) | 
#{010A} (insert tail result #{C5}) | 
#{0108} (insert tail result #{C6}) | 
#{0120} (insert tail result #{D5}) | 
#{011C} (insert tail result #{D8}) | 
#{016C} (insert tail result #{DD}) | 
#{015C} (insert tail result #{DE}) | 
#{010B} (insert tail result #{E5}) | 
#{0109} (insert tail result #{E6}) | 
#{0121} (insert tail result #{F5}) | 
#{011D} (insert tail result #{F8}) | 
#{016D} (insert tail result #{FD}) | 
#{015D} (insert tail result #{FE}) | 
#{02D9} (insert tail result #{FF}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]