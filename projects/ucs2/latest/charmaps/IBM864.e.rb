; IBM864 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/IBM864
any [
#{80} (insert tail result #{00B0}) | 
#{81} (insert tail result #{00B7}) | 
#{82} (insert tail result #{2218}) | 
#{83} (insert tail result #{221A}) | 
#{84} (insert tail result #{2592}) | 
#{85} (insert tail result #{2500}) | 
#{86} (insert tail result #{2502}) | 
#{87} (insert tail result #{253C}) | 
#{88} (insert tail result #{2524}) | 
#{89} (insert tail result #{252C}) | 
#{8A} (insert tail result #{251C}) | 
#{8B} (insert tail result #{2534}) | 
#{8C} (insert tail result #{2510}) | 
#{8D} (insert tail result #{250C}) | 
#{8E} (insert tail result #{2514}) | 
#{8F} (insert tail result #{2518}) | 
#{90} (insert tail result #{00DF}) | 
#{91} (insert tail result #{221E}) | 
#{92} (insert tail result #{00F8}) | 
#{93} (insert tail result #{00B1}) | 
#{94} (insert tail result #{00BD}) | 
#{95} (insert tail result #{00BC}) | 
#{96} (insert tail result #{2248}) | 
#{97} (insert tail result #{00AB}) | 
#{98} (insert tail result #{00BB}) | 
#{99} (insert tail result #{FEF7}) | 
#{9A} (insert tail result #{FEF8}) | 
#{9D} (insert tail result #{FEFB}) | 
#{9E} (insert tail result #{FEFC}) | 
#{9F} (insert tail result #{E016}) | 
#{A1} (insert tail result #{00AD}) | 
#{A2} (insert tail result #{FE82}) | 
#{A5} (insert tail result #{FE84}) | 
#{A8} (insert tail result #{FE8E}) | 
#{A9} (insert tail result #{0628}) | 
#{AA} (insert tail result #{062A}) | 
#{AB} (insert tail result #{062B}) | 
#{AC} (insert tail result #{060C}) | 
#{AD} (insert tail result #{062C}) | 
#{AE} (insert tail result #{062D}) | 
#{AF} (insert tail result #{062E}) | 
#{B0} (insert tail result #{0660}) | 
#{B1} (insert tail result #{0661}) | 
#{B2} (insert tail result #{0662}) | 
#{B3} (insert tail result #{0663}) | 
#{B4} (insert tail result #{0664}) | 
#{B5} (insert tail result #{0665}) | 
#{B6} (insert tail result #{0666}) | 
#{B7} (insert tail result #{0667}) | 
#{B8} (insert tail result #{0668}) | 
#{B9} (insert tail result #{0669}) | 
#{BA} (insert tail result #{06A4}) | 
#{BB} (insert tail result #{061B}) | 
#{BC} (insert tail result #{0633}) | 
#{BD} (insert tail result #{0634}) | 
#{BE} (insert tail result #{0635}) | 
#{BF} (insert tail result #{061F}) | 
#{C0} (insert tail result #{00A2}) | 
#{C1} (insert tail result #{0621}) | 
#{C2} (insert tail result #{0622}) | 
#{C3} (insert tail result #{0623}) | 
#{C4} (insert tail result #{0624}) | 
#{C5} (insert tail result #{FECA}) | 
#{C6} (insert tail result #{0626}) | 
#{C7} (insert tail result #{0627}) | 
#{C8} (insert tail result #{FE91}) | 
#{C9} (insert tail result #{0629}) | 
#{CA} (insert tail result #{FE97}) | 
#{CB} (insert tail result #{FE9B}) | 
#{CC} (insert tail result #{FE9F}) | 
#{CD} (insert tail result #{FEA3}) | 
#{CE} (insert tail result #{FEA7}) | 
#{CF} (insert tail result #{062F}) | 
#{D0} (insert tail result #{0630}) | 
#{D1} (insert tail result #{0631}) | 
#{D2} (insert tail result #{0632}) | 
#{D3} (insert tail result #{FEB3}) | 
#{D4} (insert tail result #{FEB7}) | 
#{D5} (insert tail result #{FEBB}) | 
#{D6} (insert tail result #{FEBF}) | 
#{D7} (insert tail result #{0637}) | 
#{D8} (insert tail result #{0638}) | 
#{D9} (insert tail result #{FECB}) | 
#{DA} (insert tail result #{FECF}) | 
#{DB} (insert tail result #{00A6}) | 
#{DC} (insert tail result #{00AC}) | 
#{DD} (insert tail result #{00F7}) | 
#{DE} (insert tail result #{00D7}) | 
#{DF} (insert tail result #{0639}) | 
#{E0} (insert tail result #{0640}) | 
#{E1} (insert tail result #{FED2}) | 
#{E2} (insert tail result #{FED6}) | 
#{E3} (insert tail result #{FEDB}) | 
#{E4} (insert tail result #{FEDE}) | 
#{E5} (insert tail result #{FEE3}) | 
#{E7} (insert tail result #{FEEB}) | 
#{E8} (insert tail result #{0648}) | 
#{E9} (insert tail result #{0649}) | 
#{EA} (insert tail result #{FEF3}) | 
#{EB} (insert tail result #{0636}) | 
#{EC} (insert tail result #{FEE2}) | 
#{ED} (insert tail result #{FECE}) | 
#{EE} (insert tail result #{063A}) | 
#{EF} (insert tail result #{0645}) | 
#{F0} (insert tail result #{FE7D}) | 
#{F1} (insert tail result #{0651}) | 
#{F2} (insert tail result #{0646}) | 
#{F3} (insert tail result #{0647}) | 
#{F4} (insert tail result #{FEEC}) | 
#{F5} (insert tail result #{FEF0}) | 
#{F6} (insert tail result #{FEF2}) | 
#{F7} (insert tail result #{0641}) | 
#{F8} (insert tail result #{0642}) | 
#{F9} (insert tail result #{FEF5}) | 
#{FA} (insert tail result #{FEF6}) | 
#{FB} (insert tail result #{0644}) | 
#{FC} (insert tail result #{0643}) | 
#{FD} (insert tail result #{064A}) | 
#{FE} (insert tail result #{25A0}) | 
#{FF} (insert tail result #{00A0}) | 
copy c 1 skip (insert tail result join #{00} c)
]