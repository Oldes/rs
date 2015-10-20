; IBM863 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/IBM863
any [
#{00C7} (insert tail result #{80}) | 
#{00FC} (insert tail result #{81}) | 
#{00E9} (insert tail result #{82}) | 
#{00E2} (insert tail result #{83}) | 
#{00C2} (insert tail result #{84}) | 
#{00E0} (insert tail result #{85}) | 
#{00B6} (insert tail result #{86}) | 
#{00E7} (insert tail result #{87}) | 
#{00EA} (insert tail result #{88}) | 
#{00EB} (insert tail result #{89}) | 
#{00E8} (insert tail result #{8A}) | 
#{00EF} (insert tail result #{8B}) | 
#{00EE} (insert tail result #{8C}) | 
#{00EC} (insert tail result #{8D}) | 
#{00C0} (insert tail result #{8E}) | 
#{00A7} (insert tail result #{8F}) | 
#{00C9} (insert tail result #{90}) | 
#{00C8} (insert tail result #{91}) | 
#{00CA} (insert tail result #{92}) | 
#{00F4} (insert tail result #{93}) | 
#{00CB} (insert tail result #{94}) | 
#{00CF} (insert tail result #{95}) | 
#{00FB} (insert tail result #{96}) | 
#{00F9} (insert tail result #{97}) | 
#{00A4} (insert tail result #{98}) | 
#{00D4} (insert tail result #{99}) | 
#{00DC} (insert tail result #{9A}) | 
#{00A2} (insert tail result #{9B}) | 
#{00A3} (insert tail result #{9C}) | 
#{00D9} (insert tail result #{9D}) | 
#{00DB} (insert tail result #{9E}) | 
#{0192} (insert tail result #{9F}) | 
#{00A6} (insert tail result #{A0}) | 
#{00B4} (insert tail result #{A1}) | 
#{00F3} (insert tail result #{A2}) | 
#{00FA} (insert tail result #{A3}) | 
#{00A8} (insert tail result #{A4}) | 
#{00B8} (insert tail result #{A5}) | 
#{00B3} (insert tail result #{A6}) | 
#{00AF} (insert tail result #{A7}) | 
#{00CE} (insert tail result #{A8}) | 
#{2310} (insert tail result #{A9}) | 
#{00AC} (insert tail result #{AA}) | 
#{00BD} (insert tail result #{AB}) | 
#{00BC} (insert tail result #{AC}) | 
#{00BE} (insert tail result #{AD}) | 
#{00AB} (insert tail result #{AE}) | 
#{00BB} (insert tail result #{AF}) | 
#{2591} (insert tail result #{B0}) | 
#{2592} (insert tail result #{B1}) | 
#{2593} (insert tail result #{B2}) | 
#{2502} (insert tail result #{B3}) | 
#{2524} (insert tail result #{B4}) | 
#{2561} (insert tail result #{B5}) | 
#{2562} (insert tail result #{B6}) | 
#{2556} (insert tail result #{B7}) | 
#{2555} (insert tail result #{B8}) | 
#{2563} (insert tail result #{B9}) | 
#{2551} (insert tail result #{BA}) | 
#{2557} (insert tail result #{BB}) | 
#{255D} (insert tail result #{BC}) | 
#{255C} (insert tail result #{BD}) | 
#{255B} (insert tail result #{BE}) | 
#{2510} (insert tail result #{BF}) | 
#{2514} (insert tail result #{C0}) | 
#{2534} (insert tail result #{C1}) | 
#{252C} (insert tail result #{C2}) | 
#{251C} (insert tail result #{C3}) | 
#{2500} (insert tail result #{C4}) | 
#{253C} (insert tail result #{C5}) | 
#{255E} (insert tail result #{C6}) | 
#{255F} (insert tail result #{C7}) | 
#{255A} (insert tail result #{C8}) | 
#{2554} (insert tail result #{C9}) | 
#{2569} (insert tail result #{CA}) | 
#{2566} (insert tail result #{CB}) | 
#{2560} (insert tail result #{CC}) | 
#{2550} (insert tail result #{CD}) | 
#{256C} (insert tail result #{CE}) | 
#{2567} (insert tail result #{CF}) | 
#{2568} (insert tail result #{D0}) | 
#{2564} (insert tail result #{D1}) | 
#{2565} (insert tail result #{D2}) | 
#{2559} (insert tail result #{D3}) | 
#{2558} (insert tail result #{D4}) | 
#{2552} (insert tail result #{D5}) | 
#{2553} (insert tail result #{D6}) | 
#{256B} (insert tail result #{D7}) | 
#{256A} (insert tail result #{D8}) | 
#{2518} (insert tail result #{D9}) | 
#{250C} (insert tail result #{DA}) | 
#{2588} (insert tail result #{DB}) | 
#{2584} (insert tail result #{DC}) | 
#{258C} (insert tail result #{DD}) | 
#{2590} (insert tail result #{DE}) | 
#{2580} (insert tail result #{DF}) | 
#{03B1} (insert tail result #{E0}) | 
#{00DF} (insert tail result #{E1}) | 
#{0393} (insert tail result #{E2}) | 
#{03C0} (insert tail result #{E3}) | 
#{03A3} (insert tail result #{E4}) | 
#{03C3} (insert tail result #{E5}) | 
#{00B5} (insert tail result #{E6}) | 
#{03C4} (insert tail result #{E7}) | 
#{03A6} (insert tail result #{E8}) | 
#{0398} (insert tail result #{E9}) | 
#{03A9} (insert tail result #{EA}) | 
#{03B4} (insert tail result #{EB}) | 
#{221E} (insert tail result #{EC}) | 
#{2205} (insert tail result #{ED}) | 
#{03B5} (insert tail result #{EE}) | 
#{2229} (insert tail result #{EF}) | 
#{2261} (insert tail result #{F0}) | 
#{00B1} (insert tail result #{F1}) | 
#{2265} (insert tail result #{F2}) | 
#{2264} (insert tail result #{F3}) | 
#{2320} (insert tail result #{F4}) | 
#{2321} (insert tail result #{F5}) | 
#{00F7} (insert tail result #{F6}) | 
#{2248} (insert tail result #{F7}) | 
#{2218} (insert tail result #{F8}) | 
#{00B7} (insert tail result #{F9}) | 
#{2022} (insert tail result #{FA}) | 
#{221A} (insert tail result #{FB}) | 
#{207F} (insert tail result #{FC}) | 
#{00B2} (insert tail result #{FD}) | 
#{25A0} (insert tail result #{FE}) | 
#{00A0} (insert tail result #{FF}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]