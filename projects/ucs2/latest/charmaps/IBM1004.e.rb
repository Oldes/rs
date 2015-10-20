; IBM1004 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/IBM1004
any [
#{82} (insert tail result #{201A}) | 
#{84} (insert tail result #{201E}) | 
#{85} (insert tail result #{2026}) | 
#{86} (insert tail result #{2020}) | 
#{87} (insert tail result #{2021}) | 
#{88} (insert tail result #{02C6}) | 
#{89} (insert tail result #{2030}) | 
#{8A} (insert tail result #{0160}) | 
#{8B} (insert tail result #{2039}) | 
#{8C} (insert tail result #{0152}) | 
#{91} (insert tail result #{2018}) | 
#{92} (insert tail result #{2019}) | 
#{93} (insert tail result #{201C}) | 
#{94} (insert tail result #{201D}) | 
#{95} (insert tail result #{2022}) | 
#{96} (insert tail result #{2013}) | 
#{97} (insert tail result #{2014}) | 
#{98} (insert tail result #{02DC}) | 
#{99} (insert tail result #{2122}) | 
#{9A} (insert tail result #{0161}) | 
#{9B} (insert tail result #{203A}) | 
#{9C} (insert tail result #{0153}) | 
#{9F} (insert tail result #{0178}) | 
copy c 1 skip (insert tail result join #{00} c)
]