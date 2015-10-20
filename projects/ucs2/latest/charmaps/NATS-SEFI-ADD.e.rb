; NATS-SEFI-ADD UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/NATS-SEFI-ADD
any [
#{41} (insert tail result #{00C0}) | 
#{44} (insert tail result #{0110}) | 
#{45} (insert tail result #{00C9}) | 
#{50} (insert tail result #{00DE}) | 
#{55} (insert tail result #{00DC}) | 
#{5B} (insert tail result #{00C6}) | 
#{5C} (insert tail result #{00D8}) | 
#{61} (insert tail result #{00E0}) | 
#{64} (insert tail result #{0111}) | 
#{65} (insert tail result #{00E9}) | 
#{70} (insert tail result #{00FE}) | 
#{75} (insert tail result #{00FC}) | 
#{7B} (insert tail result #{00E6}) | 
#{7C} (insert tail result #{00F8}) | 
copy c 1 skip (insert tail result join #{00} c)
]