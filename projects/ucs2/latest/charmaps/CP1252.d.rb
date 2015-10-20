; CP1252 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/CP1252
any [
#{201A} (insert tail result #{82}) | 
#{0192} (insert tail result #{83}) | 
#{201E} (insert tail result #{84}) | 
#{2026} (insert tail result #{85}) | 
#{2020} (insert tail result #{86}) | 
#{2021} (insert tail result #{87}) | 
#{02C6} (insert tail result #{88}) | 
#{2030} (insert tail result #{89}) | 
#{0160} (insert tail result #{8A}) | 
#{2039} (insert tail result #{8B}) | 
#{0152} (insert tail result #{8C}) | 
#{2018} (insert tail result #{91}) | 
#{2019} (insert tail result #{92}) | 
#{201C} (insert tail result #{93}) | 
#{201D} (insert tail result #{94}) | 
#{2022} (insert tail result #{95}) | 
#{2013} (insert tail result #{96}) | 
#{2014} (insert tail result #{97}) | 
#{02DC} (insert tail result #{98}) | 
#{2122} (insert tail result #{99}) | 
#{0161} (insert tail result #{9A}) | 
#{203A} (insert tail result #{9B}) | 
#{0153} (insert tail result #{9C}) | 
#{0178} (insert tail result #{9F}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]