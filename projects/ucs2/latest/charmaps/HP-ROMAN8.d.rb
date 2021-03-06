; HP-ROMAN8 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/HP-ROMAN8
any [
#{00C0} (insert tail result #{A1}) | 
#{00C2} (insert tail result #{A2}) | 
#{00C8} (insert tail result #{A3}) | 
#{00CA} (insert tail result #{A4}) | 
#{00CB} (insert tail result #{A5}) | 
#{00CE} (insert tail result #{A6}) | 
#{00CF} (insert tail result #{A7}) | 
#{00B4} (insert tail result #{A8}) | 
#{02CB} (insert tail result #{A9}) | 
#{02C6} (insert tail result #{AA}) | 
#{00A8} (insert tail result #{AB}) | 
#{02DC} (insert tail result #{AC}) | 
#{00D9} (insert tail result #{AD}) | 
#{00DB} (insert tail result #{AE}) | 
#{20A4} (insert tail result #{AF}) | 
#{00AF} (insert tail result #{B0}) | 
#{00DD} (insert tail result #{B1}) | 
#{00FD} (insert tail result #{B2}) | 
#{00B0} (insert tail result #{B3}) | 
#{00C7} (insert tail result #{B4}) | 
#{00E7} (insert tail result #{B5}) | 
#{00D1} (insert tail result #{B6}) | 
#{00F1} (insert tail result #{B7}) | 
#{00A1} (insert tail result #{B8}) | 
#{00BF} (insert tail result #{B9}) | 
#{00A4} (insert tail result #{BA}) | 
#{00A3} (insert tail result #{BB}) | 
#{00A5} (insert tail result #{BC}) | 
#{00A7} (insert tail result #{BD}) | 
#{0192} (insert tail result #{BE}) | 
#{00A2} (insert tail result #{BF}) | 
#{00E2} (insert tail result #{C0}) | 
#{00EA} (insert tail result #{C1}) | 
#{00F4} (insert tail result #{C2}) | 
#{00FB} (insert tail result #{C3}) | 
#{00E1} (insert tail result #{C4}) | 
#{00E9} (insert tail result #{C5}) | 
#{00F3} (insert tail result #{C6}) | 
#{00FA} (insert tail result #{C7}) | 
#{00E0} (insert tail result #{C8}) | 
#{00E8} (insert tail result #{C9}) | 
#{00F2} (insert tail result #{CA}) | 
#{00F9} (insert tail result #{CB}) | 
#{00E4} (insert tail result #{CC}) | 
#{00EB} (insert tail result #{CD}) | 
#{00F6} (insert tail result #{CE}) | 
#{00FC} (insert tail result #{CF}) | 
#{00C5} (insert tail result #{D0}) | 
#{00EE} (insert tail result #{D1}) | 
#{00D8} (insert tail result #{D2}) | 
#{00C6} (insert tail result #{D3}) | 
#{00E5} (insert tail result #{D4}) | 
#{00ED} (insert tail result #{D5}) | 
#{00F8} (insert tail result #{D6}) | 
#{00E6} (insert tail result #{D7}) | 
#{00C4} (insert tail result #{D8}) | 
#{00EC} (insert tail result #{D9}) | 
#{00D6} (insert tail result #{DA}) | 
#{00DC} (insert tail result #{DB}) | 
#{00C9} (insert tail result #{DC}) | 
#{00EF} (insert tail result #{DD}) | 
#{00DF} (insert tail result #{DE}) | 
#{00D4} (insert tail result #{DF}) | 
#{00C1} (insert tail result #{E0}) | 
#{00C3} (insert tail result #{E1}) | 
#{00E3} (insert tail result #{E2}) | 
#{00D0} (insert tail result #{E3}) | 
#{00F0} (insert tail result #{E4}) | 
#{00CD} (insert tail result #{E5}) | 
#{00CC} (insert tail result #{E6}) | 
#{00D3} (insert tail result #{E7}) | 
#{00D2} (insert tail result #{E8}) | 
#{00D5} (insert tail result #{E9}) | 
#{00F5} (insert tail result #{EA}) | 
#{0160} (insert tail result #{EB}) | 
#{0161} (insert tail result #{EC}) | 
#{00DA} (insert tail result #{ED}) | 
#{0178} (insert tail result #{EE}) | 
#{00FF} (insert tail result #{EF}) | 
#{00DE} (insert tail result #{F0}) | 
#{00FE} (insert tail result #{F1}) | 
#{00B7} (insert tail result #{F2}) | 
#{00B5} (insert tail result #{F3}) | 
#{00B6} (insert tail result #{F4}) | 
#{00BE} (insert tail result #{F5}) | 
#{2014} (insert tail result #{F6}) | 
#{00BC} (insert tail result #{F7}) | 
#{00BD} (insert tail result #{F8}) | 
#{00AA} (insert tail result #{F9}) | 
#{00BA} (insert tail result #{FA}) | 
#{00AB} (insert tail result #{FB}) | 
#{25A0} (insert tail result #{FC}) | 
#{00BB} (insert tail result #{FD}) | 
#{00B1} (insert tail result #{FE}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]