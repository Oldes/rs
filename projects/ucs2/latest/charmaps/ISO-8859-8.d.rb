; ISO-8859-8 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ISO-8859-8
any [
#{00D7} (insert tail result #{AA}) | 
#{203E} (insert tail result #{AF}) | 
#{00F7} (insert tail result #{BA}) | 
#{2017} (insert tail result #{DF}) | 
#{05D0} (insert tail result #{E0}) | 
#{05D1} (insert tail result #{E1}) | 
#{05D2} (insert tail result #{E2}) | 
#{05D3} (insert tail result #{E3}) | 
#{05D4} (insert tail result #{E4}) | 
#{05D5} (insert tail result #{E5}) | 
#{05D6} (insert tail result #{E6}) | 
#{05D7} (insert tail result #{E7}) | 
#{05D8} (insert tail result #{E8}) | 
#{05D9} (insert tail result #{E9}) | 
#{05DA} (insert tail result #{EA}) | 
#{05DB} (insert tail result #{EB}) | 
#{05DC} (insert tail result #{EC}) | 
#{05DD} (insert tail result #{ED}) | 
#{05DE} (insert tail result #{EE}) | 
#{05DF} (insert tail result #{EF}) | 
#{05E0} (insert tail result #{F0}) | 
#{05E1} (insert tail result #{F1}) | 
#{05E2} (insert tail result #{F2}) | 
#{05E3} (insert tail result #{F3}) | 
#{05E4} (insert tail result #{F4}) | 
#{05E5} (insert tail result #{F5}) | 
#{05E6} (insert tail result #{F6}) | 
#{05E7} (insert tail result #{F7}) | 
#{05E8} (insert tail result #{F8}) | 
#{05E9} (insert tail result #{F9}) | 
#{05EA} (insert tail result #{FA}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]