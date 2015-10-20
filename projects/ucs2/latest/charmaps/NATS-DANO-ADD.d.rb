; NATS-DANO-ADD UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/NATS-DANO-ADD
any [
#{00C0} (insert tail result #{41}) | 
#{0110} (insert tail result #{44}) | 
#{00C9} (insert tail result #{45}) | 
#{00DE} (insert tail result #{50}) | 
#{00DC} (insert tail result #{55}) | 
#{00C4} (insert tail result #{5B}) | 
#{00D6} (insert tail result #{5C}) | 
#{00E0} (insert tail result #{61}) | 
#{0111} (insert tail result #{64}) | 
#{00E9} (insert tail result #{65}) | 
#{00FE} (insert tail result #{70}) | 
#{00FC} (insert tail result #{75}) | 
#{00E4} (insert tail result #{7B}) | 
#{00F6} (insert tail result #{7C}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]