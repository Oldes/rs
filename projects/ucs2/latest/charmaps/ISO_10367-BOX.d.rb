; ISO_10367-BOX UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ISO_10367-BOX
any [
#{2551} (insert tail result #{C0}) | 
#{2550} (insert tail result #{C1}) | 
#{2554} (insert tail result #{C2}) | 
#{2557} (insert tail result #{C3}) | 
#{255A} (insert tail result #{C4}) | 
#{255D} (insert tail result #{C5}) | 
#{2560} (insert tail result #{C6}) | 
#{2563} (insert tail result #{C7}) | 
#{2566} (insert tail result #{C8}) | 
#{2569} (insert tail result #{C9}) | 
#{256C} (insert tail result #{CA}) | 
#{E019} (insert tail result #{CB}) | 
#{2584} (insert tail result #{CC}) | 
#{2588} (insert tail result #{CD}) | 
#{25AA} (insert tail result #{CE}) | 
#{2502} (insert tail result #{D0}) | 
#{2500} (insert tail result #{D1}) | 
#{250C} (insert tail result #{D2}) | 
#{2510} (insert tail result #{D3}) | 
#{2514} (insert tail result #{D4}) | 
#{2518} (insert tail result #{D5}) | 
#{251C} (insert tail result #{D6}) | 
#{2524} (insert tail result #{D7}) | 
#{252C} (insert tail result #{D8}) | 
#{2534} (insert tail result #{D9}) | 
#{253C} (insert tail result #{DA}) | 
#{2591} (insert tail result #{DB}) | 
#{2592} (insert tail result #{DC}) | 
#{2593} (insert tail result #{DD}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]