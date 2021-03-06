; IEC_P27-1 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/IEC_P27-1
any [
#{02C7} (insert tail result #{A0}) | 
#{2261} (insert tail result #{A1}) | 
#{2227} (insert tail result #{A2}) | 
#{2228} (insert tail result #{A3}) | 
#{2229} (insert tail result #{A4}) | 
#{222A} (insert tail result #{A5}) | 
#{2282} (insert tail result #{A6}) | 
#{2283} (insert tail result #{A7}) | 
#{21D0} (insert tail result #{A8}) | 
#{21D2} (insert tail result #{A9}) | 
#{2234} (insert tail result #{AA}) | 
#{2235} (insert tail result #{AB}) | 
#{2208} (insert tail result #{AC}) | 
#{220B} (insert tail result #{AD}) | 
#{2286} (insert tail result #{AE}) | 
#{2287} (insert tail result #{AF}) | 
#{222B} (insert tail result #{B0}) | 
#{222E} (insert tail result #{B1}) | 
#{221E} (insert tail result #{B2}) | 
#{2207} (insert tail result #{B3}) | 
#{2202} (insert tail result #{B4}) | 
#{223C} (insert tail result #{B5}) | 
#{2248} (insert tail result #{B6}) | 
#{2243} (insert tail result #{B7}) | 
#{2245} (insert tail result #{B8}) | 
#{2264} (insert tail result #{B9}) | 
#{2260} (insert tail result #{BA}) | 
#{2265} (insert tail result #{BB}) | 
#{2194} (insert tail result #{BC}) | 
#{00AC} (insert tail result #{BD}) | 
#{2200} (insert tail result #{BE}) | 
#{2203} (insert tail result #{BF}) | 
#{05D0} (insert tail result #{C0}) | 
#{25A1} (insert tail result #{C1}) | 
#{2225} (insert tail result #{C2}) | 
#{0393} (insert tail result #{C3}) | 
#{0394} (insert tail result #{C4}) | 
#{22A5} (insert tail result #{C5}) | 
#{2220} (insert tail result #{C6}) | 
#{221F} (insert tail result #{C7}) | 
#{0398} (insert tail result #{C8}) | 
#{2329} (insert tail result #{C9}) | 
#{232A} (insert tail result #{CA}) | 
#{039B} (insert tail result #{CB}) | 
#{2032} (insert tail result #{CC}) | 
#{2033} (insert tail result #{CD}) | 
#{039E} (insert tail result #{CE}) | 
#{2213} (insert tail result #{CF}) | 
#{03A0} (insert tail result #{D0}) | 
#{00B2} (insert tail result #{D1}) | 
#{03A3} (insert tail result #{D2}) | 
#{00D7} (insert tail result #{D3}) | 
#{00B3} (insert tail result #{D4}) | 
#{03A5} (insert tail result #{D5}) | 
#{03A6} (insert tail result #{D6}) | 
#{00B7} (insert tail result #{D7}) | 
#{03A8} (insert tail result #{D8}) | 
#{03A9} (insert tail result #{D9}) | 
#{2205} (insert tail result #{DA}) | 
#{21C0} (insert tail result #{DB}) | 
#{221A} (insert tail result #{DC}) | 
#{0192} (insert tail result #{DD}) | 
#{221D} (insert tail result #{DE}) | 
#{00B1} (insert tail result #{DF}) | 
#{00B0} (insert tail result #{E0}) | 
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
#{2030} (insert tail result #{EF}) | 
#{03C0} (insert tail result #{F0}) | 
#{03C1} (insert tail result #{F1}) | 
#{03C3} (insert tail result #{F2}) | 
#{00F7} (insert tail result #{F3}) | 
#{03C4} (insert tail result #{F4}) | 
#{03C5} (insert tail result #{F5}) | 
#{03C6} (insert tail result #{F6}) | 
#{03C7} (insert tail result #{F7}) | 
#{03C8} (insert tail result #{F8}) | 
#{03C9} (insert tail result #{F9}) | 
#{2020} (insert tail result #{FA}) | 
#{2190} (insert tail result #{FB}) | 
#{2191} (insert tail result #{FC}) | 
#{2192} (insert tail result #{FD}) | 
#{2193} (insert tail result #{FE}) | 
#{203E} (insert tail result #{FF}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]