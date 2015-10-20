; SAMI UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/SAMI
any [
#{00B4} (insert tail result #{A0}) | 
#{02BB} (insert tail result #{B0}) | 
#{0102} (insert tail result #{C0}) | 
#{00C0} (insert tail result #{C1}) | 
#{01DE} (insert tail result #{C2}) | 
#{01E0} (insert tail result #{C3}) | 
#{01E2} (insert tail result #{C4}) | 
#{0114} (insert tail result #{C5}) | 
#{00C8} (insert tail result #{C6}) | 
#{01E4} (insert tail result #{C7}) | 
#{01E6} (insert tail result #{C8}) | 
#{01E8} (insert tail result #{C9}) | 
#{014E} (insert tail result #{CA}) | 
#{00D2} (insert tail result #{CB}) | 
#{01EA} (insert tail result #{CC}) | 
#{01EC} (insert tail result #{CD}) | 
#{01B7} (insert tail result #{CE}) | 
#{01EE} (insert tail result #{CF}) | 
#{0103} (insert tail result #{E0}) | 
#{00E0} (insert tail result #{E1}) | 
#{01DF} (insert tail result #{E2}) | 
#{01E1} (insert tail result #{E3}) | 
#{01E3} (insert tail result #{E4}) | 
#{0115} (insert tail result #{E5}) | 
#{00E8} (insert tail result #{E6}) | 
#{01E5} (insert tail result #{E7}) | 
#{01E7} (insert tail result #{E8}) | 
#{014F} (insert tail result #{EA}) | 
#{00F2} (insert tail result #{EB}) | 
#{01EB} (insert tail result #{EC}) | 
#{0292} (insert tail result #{EE}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]