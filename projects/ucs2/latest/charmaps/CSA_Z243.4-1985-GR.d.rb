; CSA_Z243.4-1985-GR UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/CSA_Z243.4-1985-GR
any [
#{00A8} (insert tail result #{A2}) | 
#{00A2} (insert tail result #{A4}) | 
#{00B1} (insert tail result #{A6}) | 
#{00B4} (insert tail result #{A7}) | 
#{207D} (insert tail result #{A8}) | 
#{207E} (insert tail result #{A9}) | 
#{00BD} (insert tail result #{AA}) | 
#{207A} (insert tail result #{AB}) | 
#{00B8} (insert tail result #{AC}) | 
#{00B7} (insert tail result #{AE}) | 
#{207B} (insert tail result #{AF}) | 
#{2070} (insert tail result #{B0}) | 
#{00B9} (insert tail result #{B1}) | 
#{2074} (insert tail result #{B4}) | 
#{2075} (insert tail result #{B5}) | 
#{2076} (insert tail result #{B6}) | 
#{2077} (insert tail result #{B7}) | 
#{2078} (insert tail result #{B8}) | 
#{2079} (insert tail result #{B9}) | 
#{00BC} (insert tail result #{BA}) | 
#{00BE} (insert tail result #{BB}) | 
#{21D0} (insert tail result #{BC}) | 
#{2260} (insert tail result #{BD}) | 
#{2265} (insert tail result #{BE}) | 
#{00C7} (insert tail result #{C3}) | 
#{00C8} (insert tail result #{C4}) | 
#{00C9} (insert tail result #{C5}) | 
#{00CA} (insert tail result #{C6}) | 
#{00CB} (insert tail result #{C7}) | 
#{00CD} (insert tail result #{C8}) | 
#{00CE} (insert tail result #{C9}) | 
#{00CF} (insert tail result #{CA}) | 
#{00D1} (insert tail result #{CB}) | 
#{00D3} (insert tail result #{CC}) | 
#{00D4} (insert tail result #{CD}) | 
#{00D9} (insert tail result #{CE}) | 
#{00DA} (insert tail result #{CF}) | 
#{00DB} (insert tail result #{D0}) | 
#{00DC} (insert tail result #{D1}) | 
#{00AE} (insert tail result #{D2}) | 
#{00A7} (insert tail result #{D3}) | 
#{00B6} (insert tail result #{D4}) | 
#{00B5} (insert tail result #{D5}) | 
#{00AA} (insert tail result #{D6}) | 
#{00BA} (insert tail result #{D7}) | 
#{2018} (insert tail result #{D8}) | 
#{2019} (insert tail result #{D9}) | 
#{201C} (insert tail result #{DA}) | 
#{201D} (insert tail result #{DB}) | 
#{00AB} (insert tail result #{DC}) | 
#{00BB} (insert tail result #{DD}) | 
#{00B0} (insert tail result #{DE}) | 
#{00A6} (insert tail result #{DF}) | 
#{00E7} (insert tail result #{E3}) | 
#{00E8} (insert tail result #{E4}) | 
#{00E9} (insert tail result #{E5}) | 
#{00EA} (insert tail result #{E6}) | 
#{00EB} (insert tail result #{E7}) | 
#{00ED} (insert tail result #{E8}) | 
#{00EE} (insert tail result #{E9}) | 
#{00EF} (insert tail result #{EA}) | 
#{00F1} (insert tail result #{EB}) | 
#{00F3} (insert tail result #{EC}) | 
#{00F4} (insert tail result #{ED}) | 
#{00F9} (insert tail result #{EE}) | 
#{00FA} (insert tail result #{EF}) | 
#{00FB} (insert tail result #{F0}) | 
#{00FC} (insert tail result #{F1}) | 
#{00A9} (insert tail result #{F2}) | 
#{2500} (insert tail result #{F3}) | 
#{2502} (insert tail result #{F4}) | 
#{2514} (insert tail result #{F5}) | 
#{2518} (insert tail result #{F6}) | 
#{2510} (insert tail result #{F7}) | 
#{250C} (insert tail result #{F8}) | 
#{251C} (insert tail result #{F9}) | 
#{2534} (insert tail result #{FA}) | 
#{2524} (insert tail result #{FB}) | 
#{252C} (insert tail result #{FC}) | 
#{253C} (insert tail result #{FD}) | 
#{00AC} (insert tail result #{FE}) | 
#{2588} (insert tail result #{FF}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]