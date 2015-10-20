; ISO_6937-2-25 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ISO_6937-2-25
any [
#{00A4} (insert tail result #{24}) | 
#{201C} (insert tail result #{AA}) | 
#{2190} (insert tail result #{AC}) | 
#{2191} (insert tail result #{AD}) | 
#{2192} (insert tail result #{AE}) | 
#{2193} (insert tail result #{AF}) | 
#{201D} (insert tail result #{BA}) | 
#{2122} (insert tail result #{D4}) | 
#{266A} (insert tail result #{D5}) | 
#{215B} (insert tail result #{DC}) | 
#{215C} (insert tail result #{DD}) | 
#{215D} (insert tail result #{DE}) | 
#{215E} (insert tail result #{DF}) | 
#{2126} (insert tail result #{E0}) | 
#{0132} (insert tail result #{E6}) | 
#{013F} (insert tail result #{E7}) | 
#{0152} (insert tail result #{EA}) | 
#{0174} (insert tail result #{EC}) | 
#{0176} (insert tail result #{ED}) | 
#{0178} (insert tail result #{EE}) | 
#{0149} (insert tail result #{EF}) | 
#{0133} (insert tail result #{F6}) | 
#{0140} (insert tail result #{F7}) | 
#{0153} (insert tail result #{FA}) | 
#{0175} (insert tail result #{FC}) | 
#{0177} (insert tail result #{FD}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]