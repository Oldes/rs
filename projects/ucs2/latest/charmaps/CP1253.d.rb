; CP1253 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/CP1253
any [
#{201A} (insert tail result #{82}) | 
#{0192} (insert tail result #{83}) | 
#{201E} (insert tail result #{84}) | 
#{2026} (insert tail result #{85}) | 
#{2020} (insert tail result #{86}) | 
#{2021} (insert tail result #{87}) | 
#{2030} (insert tail result #{89}) | 
#{2039} (insert tail result #{8B}) | 
#{2018} (insert tail result #{91}) | 
#{2019} (insert tail result #{92}) | 
#{201C} (insert tail result #{93}) | 
#{201D} (insert tail result #{94}) | 
#{2022} (insert tail result #{95}) | 
#{2013} (insert tail result #{96}) | 
#{2014} (insert tail result #{97}) | 
#{2122} (insert tail result #{99}) | 
#{203A} (insert tail result #{9B}) | 
#{0385} (insert tail result #{A1}) | 
#{0386} (insert tail result #{A2}) | 
#{2015} (insert tail result #{AF}) | 
#{0384} (insert tail result #{B4}) | 
#{0388} (insert tail result #{B8}) | 
#{0389} (insert tail result #{B9}) | 
#{038A} (insert tail result #{BA}) | 
#{038C} (insert tail result #{BC}) | 
#{038E} (insert tail result #{BE}) | 
#{038F} (insert tail result #{BF}) | 
#{0390} (insert tail result #{C0}) | 
#{0391} (insert tail result #{C1}) | 
#{0392} (insert tail result #{C2}) | 
#{0393} (insert tail result #{C3}) | 
#{0394} (insert tail result #{C4}) | 
#{0395} (insert tail result #{C5}) | 
#{0396} (insert tail result #{C6}) | 
#{0397} (insert tail result #{C7}) | 
#{0398} (insert tail result #{C8}) | 
#{0399} (insert tail result #{C9}) | 
#{039A} (insert tail result #{CA}) | 
#{039B} (insert tail result #{CB}) | 
#{039C} (insert tail result #{CC}) | 
#{039D} (insert tail result #{CD}) | 
#{039E} (insert tail result #{CE}) | 
#{039F} (insert tail result #{CF}) | 
#{03A0} (insert tail result #{D0}) | 
#{03A1} (insert tail result #{D1}) | 
#{03A3} (insert tail result #{D3}) | 
#{03A4} (insert tail result #{D4}) | 
#{03A5} (insert tail result #{D5}) | 
#{03A6} (insert tail result #{D6}) | 
#{03A7} (insert tail result #{D7}) | 
#{03A8} (insert tail result #{D8}) | 
#{03A9} (insert tail result #{D9}) | 
#{03AA} (insert tail result #{DA}) | 
#{03AB} (insert tail result #{DB}) | 
#{03AC} (insert tail result #{DC}) | 
#{03AD} (insert tail result #{DD}) | 
#{03AE} (insert tail result #{DE}) | 
#{03AF} (insert tail result #{DF}) | 
#{03B0} (insert tail result #{E0}) | 
#{03B1} (insert tail result #{E1}) | 
#{03B2} (insert tail result #{E2}) | 
#{03B3} (insert tail result #{E3}) | 
#{03B4} (insert tail result #{E4}) | 
#{03B5} (insert tail result #{E5}) | 
#{03B6} (insert tail result #{E6}) | 
#{03B7} (insert tail result #{E7}) | 
#{03B8} (insert tail result #{E8}) | 
#{03B9} (insert tail result #{E9}) | 
#{03BA} (insert tail result #{EA}) | 
#{03BB} (insert tail result #{EB}) | 
#{03BC} (insert tail result #{EC}) | 
#{03BD} (insert tail result #{ED}) | 
#{03BE} (insert tail result #{EE}) | 
#{03BF} (insert tail result #{EF}) | 
#{03C0} (insert tail result #{F0}) | 
#{03C1} (insert tail result #{F1}) | 
#{03C2} (insert tail result #{F2}) | 
#{03C3} (insert tail result #{F3}) | 
#{03C4} (insert tail result #{F4}) | 
#{03C5} (insert tail result #{F5}) | 
#{03C6} (insert tail result #{F6}) | 
#{03C7} (insert tail result #{F7}) | 
#{03C8} (insert tail result #{F8}) | 
#{03C9} (insert tail result #{F9}) | 
#{03CA} (insert tail result #{FA}) | 
#{03CB} (insert tail result #{FB}) | 
#{03CC} (insert tail result #{FC}) | 
#{03CD} (insert tail result #{FD}) | 
#{03CE} (insert tail result #{FE}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]