; ISO_10367-BOX UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO_10367-BOX
any [
#{C0} (insert tail result #{2551}) | 
#{C1} (insert tail result #{2550}) | 
#{C2} (insert tail result #{2554}) | 
#{C3} (insert tail result #{2557}) | 
#{C4} (insert tail result #{255A}) | 
#{C5} (insert tail result #{255D}) | 
#{C6} (insert tail result #{2560}) | 
#{C7} (insert tail result #{2563}) | 
#{C8} (insert tail result #{2566}) | 
#{C9} (insert tail result #{2569}) | 
#{CA} (insert tail result #{256C}) | 
#{CB} (insert tail result #{E019}) | 
#{CC} (insert tail result #{2584}) | 
#{CD} (insert tail result #{2588}) | 
#{CE} (insert tail result #{25AA}) | 
#{D0} (insert tail result #{2502}) | 
#{D1} (insert tail result #{2500}) | 
#{D2} (insert tail result #{250C}) | 
#{D3} (insert tail result #{2510}) | 
#{D4} (insert tail result #{2514}) | 
#{D5} (insert tail result #{2518}) | 
#{D6} (insert tail result #{251C}) | 
#{D7} (insert tail result #{2524}) | 
#{D8} (insert tail result #{252C}) | 
#{D9} (insert tail result #{2534}) | 
#{DA} (insert tail result #{253C}) | 
#{DB} (insert tail result #{2591}) | 
#{DC} (insert tail result #{2592}) | 
#{DD} (insert tail result #{2593}) | 
copy c 1 skip (insert tail result join #{00} c)
]