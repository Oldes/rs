; CP1251 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/CP1251
any [
#{0402} (insert tail result #{80}) | 
#{0403} (insert tail result #{81}) | 
#{201A} (insert tail result #{82}) | 
#{0453} (insert tail result #{83}) | 
#{201E} (insert tail result #{84}) | 
#{2026} (insert tail result #{85}) | 
#{2020} (insert tail result #{86}) | 
#{2021} (insert tail result #{87}) | 
#{2030} (insert tail result #{89}) | 
#{0409} (insert tail result #{8A}) | 
#{2039} (insert tail result #{8B}) | 
#{040A} (insert tail result #{8C}) | 
#{040C} (insert tail result #{8D}) | 
#{040B} (insert tail result #{8E}) | 
#{040F} (insert tail result #{8F}) | 
#{0452} (insert tail result #{90}) | 
#{2018} (insert tail result #{91}) | 
#{2019} (insert tail result #{92}) | 
#{201C} (insert tail result #{93}) | 
#{201D} (insert tail result #{94}) | 
#{2022} (insert tail result #{95}) | 
#{2013} (insert tail result #{96}) | 
#{2014} (insert tail result #{97}) | 
#{2122} (insert tail result #{99}) | 
#{0459} (insert tail result #{9A}) | 
#{203A} (insert tail result #{9B}) | 
#{045A} (insert tail result #{9C}) | 
#{045C} (insert tail result #{9D}) | 
#{045B} (insert tail result #{9E}) | 
#{045F} (insert tail result #{9F}) | 
#{040E} (insert tail result #{A1}) | 
#{045E} (insert tail result #{A2}) | 
#{0408} (insert tail result #{A3}) | 
#{0490} (insert tail result #{A5}) | 
#{0401} (insert tail result #{A8}) | 
#{0404} (insert tail result #{AA}) | 
#{0407} (insert tail result #{AF}) | 
#{0406} (insert tail result #{B2}) | 
#{0456} (insert tail result #{B3}) | 
#{0491} (insert tail result #{B4}) | 
#{0451} (insert tail result #{B8}) | 
#{2116} (insert tail result #{B9}) | 
#{0454} (insert tail result #{BA}) | 
#{0458} (insert tail result #{BC}) | 
#{0405} (insert tail result #{BD}) | 
#{0455} (insert tail result #{BE}) | 
#{0457} (insert tail result #{BF}) | 
#{0410} (insert tail result #{C0}) | 
#{0411} (insert tail result #{C1}) | 
#{0412} (insert tail result #{C2}) | 
#{0413} (insert tail result #{C3}) | 
#{0414} (insert tail result #{C4}) | 
#{0415} (insert tail result #{C5}) | 
#{0416} (insert tail result #{C6}) | 
#{0417} (insert tail result #{C7}) | 
#{0418} (insert tail result #{C8}) | 
#{0419} (insert tail result #{C9}) | 
#{041A} (insert tail result #{CA}) | 
#{041B} (insert tail result #{CB}) | 
#{041C} (insert tail result #{CC}) | 
#{041D} (insert tail result #{CD}) | 
#{041E} (insert tail result #{CE}) | 
#{041F} (insert tail result #{CF}) | 
#{0420} (insert tail result #{D0}) | 
#{0421} (insert tail result #{D1}) | 
#{0422} (insert tail result #{D2}) | 
#{0423} (insert tail result #{D3}) | 
#{0424} (insert tail result #{D4}) | 
#{0425} (insert tail result #{D5}) | 
#{0426} (insert tail result #{D6}) | 
#{0427} (insert tail result #{D7}) | 
#{0428} (insert tail result #{D8}) | 
#{0429} (insert tail result #{D9}) | 
#{042A} (insert tail result #{DA}) | 
#{042B} (insert tail result #{DB}) | 
#{042C} (insert tail result #{DC}) | 
#{042D} (insert tail result #{DD}) | 
#{042E} (insert tail result #{DE}) | 
#{042F} (insert tail result #{DF}) | 
#{0430} (insert tail result #{E0}) | 
#{0431} (insert tail result #{E1}) | 
#{0432} (insert tail result #{E2}) | 
#{0433} (insert tail result #{E3}) | 
#{0434} (insert tail result #{E4}) | 
#{0435} (insert tail result #{E5}) | 
#{0436} (insert tail result #{E6}) | 
#{0437} (insert tail result #{E7}) | 
#{0438} (insert tail result #{E8}) | 
#{0439} (insert tail result #{E9}) | 
#{043A} (insert tail result #{EA}) | 
#{043B} (insert tail result #{EB}) | 
#{043C} (insert tail result #{EC}) | 
#{043D} (insert tail result #{ED}) | 
#{043E} (insert tail result #{EE}) | 
#{043F} (insert tail result #{EF}) | 
#{0440} (insert tail result #{F0}) | 
#{0441} (insert tail result #{F1}) | 
#{0442} (insert tail result #{F2}) | 
#{0443} (insert tail result #{F3}) | 
#{0444} (insert tail result #{F4}) | 
#{0445} (insert tail result #{F5}) | 
#{0446} (insert tail result #{F6}) | 
#{0447} (insert tail result #{F7}) | 
#{0448} (insert tail result #{F8}) | 
#{0449} (insert tail result #{F9}) | 
#{044A} (insert tail result #{FA}) | 
#{044B} (insert tail result #{FB}) | 
#{044C} (insert tail result #{FC}) | 
#{044D} (insert tail result #{FD}) | 
#{044E} (insert tail result #{FE}) | 
#{044F} (insert tail result #{FF}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]