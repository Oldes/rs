; JIS_C6229-1984-KANA UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/JIS_C6229-1984-KANA
any [
#{300C} (insert tail result #{22}) | 
#{300D} (insert tail result #{23}) | 
#{30F2} (insert tail result #{26}) | 
#{30A2} (insert tail result #{31}) | 
#{30A4} (insert tail result #{32}) | 
#{30A6} (insert tail result #{33}) | 
#{30A8} (insert tail result #{34}) | 
#{30AA} (insert tail result #{35}) | 
#{30AB} (insert tail result #{36}) | 
#{30AD} (insert tail result #{37}) | 
#{30AF} (insert tail result #{38}) | 
#{30B1} (insert tail result #{39}) | 
#{30B3} (insert tail result #{3A}) | 
#{30B5} (insert tail result #{3B}) | 
#{30B7} (insert tail result #{3C}) | 
#{30B9} (insert tail result #{3D}) | 
#{30BB} (insert tail result #{3E}) | 
#{30BD} (insert tail result #{3F}) | 
#{30BF} (insert tail result #{40}) | 
#{30C1} (insert tail result #{41}) | 
#{30C4} (insert tail result #{42}) | 
#{30C6} (insert tail result #{43}) | 
#{30C8} (insert tail result #{44}) | 
#{30CA} (insert tail result #{45}) | 
#{30CB} (insert tail result #{46}) | 
#{30CC} (insert tail result #{47}) | 
#{30CD} (insert tail result #{48}) | 
#{30CE} (insert tail result #{49}) | 
#{30CF} (insert tail result #{4A}) | 
#{30D2} (insert tail result #{4B}) | 
#{30D5} (insert tail result #{4C}) | 
#{30D8} (insert tail result #{4D}) | 
#{30DB} (insert tail result #{4E}) | 
#{30DE} (insert tail result #{4F}) | 
#{30DF} (insert tail result #{50}) | 
#{30E0} (insert tail result #{51}) | 
#{30E1} (insert tail result #{52}) | 
#{30E2} (insert tail result #{53}) | 
#{30E4} (insert tail result #{54}) | 
#{30E6} (insert tail result #{55}) | 
#{30E8} (insert tail result #{56}) | 
#{30E9} (insert tail result #{57}) | 
#{30EA} (insert tail result #{58}) | 
#{30EB} (insert tail result #{59}) | 
#{30EC} (insert tail result #{5A}) | 
#{30ED} (insert tail result #{5B}) | 
#{30EF} (insert tail result #{5C}) | 
#{30F3} (insert tail result #{5D}) | 
#{309B} (insert tail result #{5E}) | 
#{309C} (insert tail result #{5F}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]