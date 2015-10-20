; NATS-DANO UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/NATS-DANO
any [
#{22} (insert tail result #{00AB}) | 
#{23} (insert tail result #{00BB}) | 
#{40} (insert tail result #{E018}) | 
#{5B} (insert tail result #{00C6}) | 
#{5C} (insert tail result #{00D8}) | 
#{5D} (insert tail result #{00C5}) | 
#{5E} (insert tail result #{25A0}) | 
#{60} (insert tail result #{E019}) | 
#{7B} (insert tail result #{00E6}) | 
#{7C} (insert tail result #{00F8}) | 
#{7D} (insert tail result #{00E5}) | 
#{7E} (insert tail result #{2013}) | 
copy c 1 skip (insert tail result join #{00} c)
]