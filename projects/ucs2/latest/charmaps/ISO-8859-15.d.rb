; ISO-8859-15 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ISO-8859-15
any [
#{20AC} (insert tail result #{A4}) | 
#{0160} (insert tail result #{A6}) | 
#{0161} (insert tail result #{A8}) | 
#{017D} (insert tail result #{B4}) | 
#{017E} (insert tail result #{B8}) | 
#{0152} (insert tail result #{BC}) | 
#{0153} (insert tail result #{BD}) | 
#{0178} (insert tail result #{BE}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]