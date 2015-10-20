; NATS-SEFI UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/NATS-SEFI
any [
#{40} (insert tail result #{E018}) | 
#{5B} (insert tail result #{00C4}) | 
#{5C} (insert tail result #{00D6}) | 
#{5D} (insert tail result #{00C5}) | 
#{5E} (insert tail result #{25A0}) | 
#{60} (insert tail result #{E019}) | 
#{7B} (insert tail result #{00E4}) | 
#{7C} (insert tail result #{00F6}) | 
#{7D} (insert tail result #{00E5}) | 
#{7E} (insert tail result #{2013}) | 
copy c 1 skip (insert tail result join #{00} c)
]