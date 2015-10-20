; JUS_I.B1.002 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/JUS_I.B1.002
any [
#{017D} (insert tail result #{40}) | 
#{0160} (insert tail result #{5B}) | 
#{0110} (insert tail result #{5C}) | 
#{0106} (insert tail result #{5D}) | 
#{010C} (insert tail result #{5E}) | 
#{017E} (insert tail result #{60}) | 
#{0161} (insert tail result #{7B}) | 
#{0111} (insert tail result #{7C}) | 
#{0107} (insert tail result #{7D}) | 
#{010D} (insert tail result #{7E}) | 
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (decodeUnknownChar c)
]