; ISO_8859-2 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ISO_8859-2
; created: 13-Oct-2003/10:23:16+2:00
any [
#{0104} (insert tail result #{A1}) | ; LATIN CAPITAL LETTER A WITH OGONEK
#{02D8} (insert tail result #{A2}) | ; BREVE
#{0141} (insert tail result #{A3}) | ; LATIN CAPITAL LETTER L WITH STROKE
#{013D} (insert tail result #{A5}) | ; LATIN CAPITAL LETTER L WITH CARON
#{015A} (insert tail result #{A6}) | ; LATIN CAPITAL LETTER S WITH ACUTE
#{0160} (insert tail result #{A9}) | ; LATIN CAPITAL LETTER S WITH CARON
#{015E} (insert tail result #{AA}) | ; LATIN CAPITAL LETTER S WITH CEDILLA
#{0164} (insert tail result #{AB}) | ; LATIN CAPITAL LETTER T WITH CARON
#{0179} (insert tail result #{AC}) | ; LATIN CAPITAL LETTER Z WITH ACUTE
#{017D} (insert tail result #{AE}) | ; LATIN CAPITAL LETTER Z WITH CARON
#{017B} (insert tail result #{AF}) | ; LATIN CAPITAL LETTER Z WITH DOT ABOVE
#{0105} (insert tail result #{B1}) | ; LATIN SMALL LETTER A WITH OGONEK
#{02DB} (insert tail result #{B2}) | ; OGONEK
#{0142} (insert tail result #{B3}) | ; LATIN SMALL LETTER L WITH STROKE
#{013E} (insert tail result #{B5}) | ; LATIN SMALL LETTER L WITH CARON
#{015B} (insert tail result #{B6}) | ; LATIN SMALL LETTER S WITH ACUTE
#{02C7} (insert tail result #{B7}) | ; CARON (Mandarin Chinese third tone)
#{0161} (insert tail result #{B9}) | ; LATIN SMALL LETTER S WITH CARON
#{015F} (insert tail result #{BA}) | ; LATIN SMALL LETTER S WITH CEDILLA
#{0165} (insert tail result #{BB}) | ; LATIN SMALL LETTER T WITH CARON
#{017A} (insert tail result #{BC}) | ; LATIN SMALL LETTER Z WITH ACUTE
#{02DD} (insert tail result #{BD}) | ; DOUBLE ACUTE ACCENT
#{017E} (insert tail result #{BE}) | ; LATIN SMALL LETTER Z WITH CARON
#{017C} (insert tail result #{BF}) | ; LATIN SMALL LETTER Z WITH DOT ABOVE
#{0154} (insert tail result #{C0}) | ; LATIN CAPITAL LETTER R WITH ACUTE
#{0102} (insert tail result #{C3}) | ; LATIN CAPITAL LETTER A WITH BREVE
#{0139} (insert tail result #{C5}) | ; LATIN CAPITAL LETTER L WITH ACUTE
#{0106} (insert tail result #{C6}) | ; LATIN CAPITAL LETTER C WITH ACUTE
#{010C} (insert tail result #{C8}) | ; LATIN CAPITAL LETTER C WITH CARON
#{0118} (insert tail result #{CA}) | ; LATIN CAPITAL LETTER E WITH OGONEK
#{011A} (insert tail result #{CC}) | ; LATIN CAPITAL LETTER E WITH CARON
#{010E} (insert tail result #{CF}) | ; LATIN CAPITAL LETTER D WITH CARON
#{0110} (insert tail result #{D0}) | ; LATIN CAPITAL LETTER D WITH STROKE
#{0143} (insert tail result #{D1}) | ; LATIN CAPITAL LETTER N WITH ACUTE
#{0147} (insert tail result #{D2}) | ; LATIN CAPITAL LETTER N WITH CARON
#{0150} (insert tail result #{D5}) | ; LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
#{0158} (insert tail result #{D8}) | ; LATIN CAPITAL LETTER R WITH CARON
#{016E} (insert tail result #{D9}) | ; LATIN CAPITAL LETTER U WITH RING ABOVE
#{0170} (insert tail result #{DB}) | ; LATIN CAPITAL LETTER U WITH DOUBLE ACUTE
#{0162} (insert tail result #{DE}) | ; LATIN CAPITAL LETTER T WITH CEDILLA
#{0155} (insert tail result #{E0}) | ; LATIN SMALL LETTER R WITH ACUTE
#{0103} (insert tail result #{E3}) | ; LATIN SMALL LETTER A WITH BREVE
#{013A} (insert tail result #{E5}) | ; LATIN SMALL LETTER L WITH ACUTE
#{0107} (insert tail result #{E6}) | ; LATIN SMALL LETTER C WITH ACUTE
#{010D} (insert tail result #{E8}) | ; LATIN SMALL LETTER C WITH CARON
#{0119} (insert tail result #{EA}) | ; LATIN SMALL LETTER E WITH OGONEK
#{011B} (insert tail result #{EC}) | ; LATIN SMALL LETTER E WITH CARON
#{010F} (insert tail result #{EF}) | ; LATIN SMALL LETTER D WITH CARON
#{0111} (insert tail result #{F0}) | ; LATIN SMALL LETTER D WITH STROKE
#{0144} (insert tail result #{F1}) | ; LATIN SMALL LETTER N WITH ACUTE
#{0148} (insert tail result #{F2}) | ; LATIN SMALL LETTER N WITH CARON
#{0151} (insert tail result #{F5}) | ; LATIN SMALL LETTER O WITH DOUBLE ACUTE
#{0159} (insert tail result #{F8}) | ; LATIN SMALL LETTER R WITH CARON
#{016F} (insert tail result #{F9}) | ; LATIN SMALL LETTER U WITH RING ABOVE
#{0171} (insert tail result #{FB}) | ; LATIN SMALL LETTER U WITH DOUBLE ACUTE
#{0163} (insert tail result #{FE}) | ; LATIN SMALL LETTER T WITH CEDILLA
#{02D9} (insert tail result #{FF}) | ; DOT ABOVE (Mandarin Chinese light tone)
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (insert tail result c print rejoin [{!!! Unknown UCS-2 octet: } mold c])
]