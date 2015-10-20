; ISO-8859-5 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ISO-8859-5
any [
#{0401} (insert tail result #{A1}) | 
#{0402} (insert tail result #{A2}) | 
#{0403} (insert tail result #{A3}) | 
#{0404} (insert tail result #{A4}) | 
#{0405} (insert tail result #{A5}) | 
#{0406} (insert tail result #{A6}) | 
#{0407} (insert tail result #{A7}) | 
#{0408} (insert tail result #{A8}) | 
#{0409} (insert tail result #{A9}) | 
#{040A} (insert tail result #{AA}) | 
#{040B} (insert tail result #{AB}) | 
#{040C} (insert tail result #{AC}) | 
#{040E} (insert tail result #{AE}) | 
#{040F} (insert tail result #{AF}) | 
#{0410} (insert tail result #{B0}) | 
#{0411} (insert tail result #{B1}) | 
#{0412} (insert tail result #{B2}) | 
#{0413} (insert tail result #{B3}) | 
#{0414} (insert tail result #{B4}) | 
#{0415} (insert tail result #{B5}) | 
#{0416} (insert tail result #{B6}) | 
#{0417} (insert tail result #{B7}) | 
#{0418} (insert tail result #{B8}) | 
#{0419} (insert tail result #{B9}) | 
#{041A} (insert tail result #{BA}) | 
#{041B} (insert tail result #{BB}) | 
#{041C} (insert tail result #{BC}) | 
#{041D} (insert tail result #{BD}) | 
#{041E} (insert tail result #{BE}) | 
#{041F} (insert tail result #{BF}) | 
#{0420} (insert tail result #{C0}) | 
#{0421} (insert tail result #{C1}) | 
#{0422} (insert tail result #{C2}) | 
#{0423} (insert tail result #{C3}) | 
#{0424} (insert tail result #{C4}) | 
#{0425} (insert tail result #{C5}) | 
#{0426} (insert tail result #{C6}) | 
#{0427} (insert tail result #{C7}) | 
#{0428} (insert tail result #{C8}) | 
#{0429} (insert tail result #{C9}) | 
#{042A} (insert tail result #{CA}) | 
#{042B} (insert tail result #{CB}) | 
#{042C} (insert tail result #{CC}) | 
#{042D} (insert tail result #{CD}) | 
#{042E} (insert tail result #{CE}) | 
#{042F} (insert tail result #{CF}) | 
#{0430} (insert tail result #{D0}) | 
#{0431} (insert tail result #{D1}) | 
#{0432} (insert tail result #{D2}) | 
#{0433} (insert tail result #{D3}) | 
#{0434} (insert tail result #{D4}) | 
#{0435} (insert tail result #{D5}) | 
#{0436} (insert tail result #{D6}) | 
#{0437} (insert tail result #{D7}) | 
#{0438} (insert tail result #{D8}) | 
#{0439} (insert tail result #{D9}) | 
#{043A} (insert tail result #{DA}) | 
#{043B} (insert tail result #{DB}) | 
#{043C} (insert tail result #{DC}) | 
#{043D} (insert tail result #{DD}) | 
#{043E} (insert tail result #{DE}) | 
#{043F} (insert tail result #{DF}) | 
#{0440} (insert tail result #{E0}) | 
#{0441} (insert tail result #{E1}) | 
#{0442} (insert tail result #{E2}) | 
#{0443} (insert tail result #{E3}) | 
#{0444} (insert tail result #{E4}) | 
#{0445} (insert tail result #{E5}) | 
#{0446} (insert tail result #{E6}) | 
#{0447} (insert tail result #{E7}) | 
#{0448} (insert tail result #{E8}) | 
#{0449} (insert tail result #{E9}) | 
#{044A} (insert tail result #{EA}) | 
#{044B} (insert tail result #{EB}) | 
#{044C} (insert tail result #{EC}) | 
#{044D} (insert tail result #{ED}) | 
#{044E} (insert tail result #{EE}) | 
#{044F} (insert tail result #{EF}) | 
#{2116} (insert tail result #{F0}) | 
#{0451} (insert tail result #{F1}) | 
#{0452} (insert tail result #{F2}) | 
#{0453} (insert tail result #{F3}) | 
#{0454} (insert tail result #{F4}) | 
#{0455} (insert tail result #{F5}) | 
#{0456} (insert tail result #{F6}) | 
#{0457} (insert tail result #{F7}) | 
#{0458} (insert tail result #{F8}) | 
#{0459} (insert tail result #{F9}) | 
#{045A} (insert tail result #{FA}) | 
#{045B} (insert tail result #{FB}) | 
#{045C} (insert tail result #{FC}) | 
#{00A7} (insert tail result #{FD}) | 
#{045E} (insert tail result #{FE}) | 
#{045F} (insert tail result #{FF}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]