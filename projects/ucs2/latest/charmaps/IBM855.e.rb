; IBM855 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/IBM855
any [
#{80} (insert tail result #{0452}) | 
#{81} (insert tail result #{0402}) | 
#{82} (insert tail result #{0453}) | 
#{83} (insert tail result #{0403}) | 
#{84} (insert tail result #{0451}) | 
#{85} (insert tail result #{0401}) | 
#{86} (insert tail result #{0454}) | 
#{87} (insert tail result #{0404}) | 
#{88} (insert tail result #{0455}) | 
#{89} (insert tail result #{0405}) | 
#{8A} (insert tail result #{0456}) | 
#{8B} (insert tail result #{0406}) | 
#{8C} (insert tail result #{0457}) | 
#{8D} (insert tail result #{0407}) | 
#{8E} (insert tail result #{0458}) | 
#{8F} (insert tail result #{0408}) | 
#{90} (insert tail result #{0459}) | 
#{91} (insert tail result #{0409}) | 
#{92} (insert tail result #{045A}) | 
#{93} (insert tail result #{040A}) | 
#{94} (insert tail result #{045B}) | 
#{95} (insert tail result #{0093}) | 
#{96} (insert tail result #{045C}) | 
#{97} (insert tail result #{040C}) | 
#{98} (insert tail result #{045E}) | 
#{99} (insert tail result #{040E}) | 
#{9A} (insert tail result #{045F}) | 
#{9B} (insert tail result #{040F}) | 
#{9C} (insert tail result #{044E}) | 
#{9D} (insert tail result #{042E}) | 
#{9E} (insert tail result #{044A}) | 
#{9F} (insert tail result #{042A}) | 
#{A0} (insert tail result #{0430}) | 
#{A1} (insert tail result #{0410}) | 
#{A2} (insert tail result #{0431}) | 
#{A3} (insert tail result #{0411}) | 
#{A4} (insert tail result #{0446}) | 
#{A5} (insert tail result #{0426}) | 
#{A6} (insert tail result #{0434}) | 
#{A7} (insert tail result #{0414}) | 
#{A8} (insert tail result #{0435}) | 
#{A9} (insert tail result #{0415}) | 
#{AA} (insert tail result #{0444}) | 
#{AB} (insert tail result #{0424}) | 
#{AC} (insert tail result #{0433}) | 
#{AD} (insert tail result #{0413}) | 
#{AE} (insert tail result #{00AB}) | 
#{AF} (insert tail result #{00BB}) | 
#{B0} (insert tail result #{2591}) | 
#{B1} (insert tail result #{2592}) | 
#{B2} (insert tail result #{2593}) | 
#{B3} (insert tail result #{2502}) | 
#{B4} (insert tail result #{2524}) | 
#{B5} (insert tail result #{0445}) | 
#{B6} (insert tail result #{0425}) | 
#{B7} (insert tail result #{0438}) | 
#{B8} (insert tail result #{0418}) | 
#{B9} (insert tail result #{2563}) | 
#{BA} (insert tail result #{2551}) | 
#{BB} (insert tail result #{2557}) | 
#{BC} (insert tail result #{255D}) | 
#{BD} (insert tail result #{0439}) | 
#{BE} (insert tail result #{0419}) | 
#{BF} (insert tail result #{2510}) | 
#{C0} (insert tail result #{2514}) | 
#{C1} (insert tail result #{2534}) | 
#{C2} (insert tail result #{252C}) | 
#{C3} (insert tail result #{251C}) | 
#{C4} (insert tail result #{2500}) | 
#{C5} (insert tail result #{253C}) | 
#{C6} (insert tail result #{043A}) | 
#{C7} (insert tail result #{041A}) | 
#{C8} (insert tail result #{255A}) | 
#{C9} (insert tail result #{2554}) | 
#{CA} (insert tail result #{2569}) | 
#{CB} (insert tail result #{2566}) | 
#{CC} (insert tail result #{2560}) | 
#{CD} (insert tail result #{2550}) | 
#{CE} (insert tail result #{256C}) | 
#{CF} (insert tail result #{00A4}) | 
#{D0} (insert tail result #{043B}) | 
#{D1} (insert tail result #{041B}) | 
#{D2} (insert tail result #{043C}) | 
#{D3} (insert tail result #{041C}) | 
#{D4} (insert tail result #{043D}) | 
#{D5} (insert tail result #{041D}) | 
#{D6} (insert tail result #{043E}) | 
#{D7} (insert tail result #{041E}) | 
#{D8} (insert tail result #{043F}) | 
#{D9} (insert tail result #{2518}) | 
#{DA} (insert tail result #{250C}) | 
#{DB} (insert tail result #{2588}) | 
#{DC} (insert tail result #{2584}) | 
#{DD} (insert tail result #{041F}) | 
#{DE} (insert tail result #{044F}) | 
#{DF} (insert tail result #{2580}) | 
#{E0} (insert tail result #{042F}) | 
#{E1} (insert tail result #{0440}) | 
#{E2} (insert tail result #{0420}) | 
#{E3} (insert tail result #{0441}) | 
#{E4} (insert tail result #{0421}) | 
#{E5} (insert tail result #{0442}) | 
#{E6} (insert tail result #{0422}) | 
#{E7} (insert tail result #{0443}) | 
#{E8} (insert tail result #{0423}) | 
#{E9} (insert tail result #{0436}) | 
#{EA} (insert tail result #{0416}) | 
#{EB} (insert tail result #{0432}) | 
#{EC} (insert tail result #{0412}) | 
#{ED} (insert tail result #{044C}) | 
#{EE} (insert tail result #{042C}) | 
#{EF} (insert tail result #{00B4}) | 
#{F0} (insert tail result #{00AD}) | 
#{F1} (insert tail result #{044B}) | 
#{F2} (insert tail result #{042B}) | 
#{F3} (insert tail result #{0437}) | 
#{F4} (insert tail result #{0417}) | 
#{F5} (insert tail result #{0448}) | 
#{F6} (insert tail result #{0428}) | 
#{F7} (insert tail result #{044D}) | 
#{F8} (insert tail result #{042D}) | 
#{F9} (insert tail result #{0449}) | 
#{FA} (insert tail result #{0429}) | 
#{FB} (insert tail result #{0447}) | 
#{FC} (insert tail result #{0427}) | 
#{FE} (insert tail result #{25A0}) | 
#{FF} (insert tail result #{00A0}) | 
copy c 1 skip (insert tail result join #{00} c)
]