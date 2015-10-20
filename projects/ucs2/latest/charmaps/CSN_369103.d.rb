; CSN_369103 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/CSN_369103
any [
#{00A4} (insert tail result #{24}) | 
#{0104} (insert tail result #{A1}) | 
#{02D8} (insert tail result #{A2}) | 
#{0141} (insert tail result #{A3}) | 
#{0024} (insert tail result #{A4}) | 
#{013D} (insert tail result #{A5}) | 
#{015A} (insert tail result #{A6}) | 
#{0160} (insert tail result #{A9}) | 
#{015E} (insert tail result #{AA}) | 
#{0164} (insert tail result #{AB}) | 
#{0179} (insert tail result #{AC}) | 
#{017D} (insert tail result #{AE}) | 
#{017B} (insert tail result #{AF}) | 
#{0105} (insert tail result #{B1}) | 
#{02DB} (insert tail result #{B2}) | 
#{0142} (insert tail result #{B3}) | 
#{013E} (insert tail result #{B5}) | 
#{015B} (insert tail result #{B6}) | 
#{02C7} (insert tail result #{B7}) | 
#{0161} (insert tail result #{B9}) | 
#{015F} (insert tail result #{BA}) | 
#{0165} (insert tail result #{BB}) | 
#{017A} (insert tail result #{BC}) | 
#{02DD} (insert tail result #{BD}) | 
#{017E} (insert tail result #{BE}) | 
#{017C} (insert tail result #{BF}) | 
#{0154} (insert tail result #{C0}) | 
#{0102} (insert tail result #{C3}) | 
#{0139} (insert tail result #{C5}) | 
#{0106} (insert tail result #{C6}) | 
#{010C} (insert tail result #{C8}) | 
#{0118} (insert tail result #{CA}) | 
#{011A} (insert tail result #{CC}) | 
#{010E} (insert tail result #{CF}) | 
#{0110} (insert tail result #{D0}) | 
#{0143} (insert tail result #{D1}) | 
#{0147} (insert tail result #{D2}) | 
#{0150} (insert tail result #{D5}) | 
#{0158} (insert tail result #{D8}) | 
#{016E} (insert tail result #{D9}) | 
#{0170} (insert tail result #{DB}) | 
#{0162} (insert tail result #{DE}) | 
#{0155} (insert tail result #{E0}) | 
#{0103} (insert tail result #{E3}) | 
#{013A} (insert tail result #{E5}) | 
#{0107} (insert tail result #{E6}) | 
#{010D} (insert tail result #{E8}) | 
#{0119} (insert tail result #{EA}) | 
#{011B} (insert tail result #{EC}) | 
#{010F} (insert tail result #{EF}) | 
#{0111} (insert tail result #{F0}) | 
#{0144} (insert tail result #{F1}) | 
#{0148} (insert tail result #{F2}) | 
#{0151} (insert tail result #{F5}) | 
#{0159} (insert tail result #{F8}) | 
#{016F} (insert tail result #{F9}) | 
#{0171} (insert tail result #{FB}) | 
#{0163} (insert tail result #{FE}) | 
#{02D9} (insert tail result #{FF}) | 
#{0024} (insert tail result #{A4}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]