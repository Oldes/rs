; NATS-SEFI UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/NATS-SEFI
any [
#{E018} (insert tail result #{40}) | 
#{00C4} (insert tail result #{5B}) | 
#{00D6} (insert tail result #{5C}) | 
#{00C5} (insert tail result #{5D}) | 
#{25A0} (insert tail result #{5E}) | 
#{E019} (insert tail result #{60}) | 
#{00E4} (insert tail result #{7B}) | 
#{00F6} (insert tail result #{7C}) | 
#{00E5} (insert tail result #{7D}) | 
#{2013} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]