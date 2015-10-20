; IBM862 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/IBM862
any [
#{80} (insert tail result #{05D0}) | 
#{81} (insert tail result #{05D1}) | 
#{82} (insert tail result #{05D2}) | 
#{83} (insert tail result #{05D3}) | 
#{84} (insert tail result #{05D4}) | 
#{85} (insert tail result #{05D5}) | 
#{86} (insert tail result #{05D6}) | 
#{87} (insert tail result #{05D7}) | 
#{88} (insert tail result #{05D8}) | 
#{89} (insert tail result #{05D9}) | 
#{8A} (insert tail result #{05DA}) | 
#{8B} (insert tail result #{05DB}) | 
#{8C} (insert tail result #{05DC}) | 
#{8D} (insert tail result #{05DD}) | 
#{8E} (insert tail result #{05DE}) | 
#{8F} (insert tail result #{05DF}) | 
#{90} (insert tail result #{05E0}) | 
#{91} (insert tail result #{05E1}) | 
#{92} (insert tail result #{05E2}) | 
#{93} (insert tail result #{05E3}) | 
#{94} (insert tail result #{05E4}) | 
#{95} (insert tail result #{05E5}) | 
#{96} (insert tail result #{05E6}) | 
#{97} (insert tail result #{05E7}) | 
#{98} (insert tail result #{05E8}) | 
#{99} (insert tail result #{05E9}) | 
#{9A} (insert tail result #{05EA}) | 
#{9B} (insert tail result #{00A2}) | 
#{9C} (insert tail result #{00A3}) | 
#{9D} (insert tail result #{00D9}) | 
#{9E} (insert tail result #{20A7}) | 
#{9F} (insert tail result #{00D2}) | 
#{A0} (insert tail result #{00E1}) | 
#{A1} (insert tail result #{00ED}) | 
#{A2} (insert tail result #{00F3}) | 
#{A3} (insert tail result #{00FA}) | 
#{A4} (insert tail result #{00F1}) | 
#{A5} (insert tail result #{00D1}) | 
#{A6} (insert tail result #{00AA}) | 
#{A7} (insert tail result #{00BA}) | 
#{A8} (insert tail result #{00BF}) | 
#{AA} (insert tail result #{00AC}) | 
#{AB} (insert tail result #{00BD}) | 
#{AC} (insert tail result #{00BC}) | 
#{AD} (insert tail result #{00A1}) | 
#{AE} (insert tail result #{00AB}) | 
#{AF} (insert tail result #{00BB}) | 
#{B0} (insert tail result #{2591}) | 
#{B1} (insert tail result #{2592}) | 
#{B2} (insert tail result #{2593}) | 
#{B3} (insert tail result #{2502}) | 
#{B4} (insert tail result #{2524}) | 
#{B5} (insert tail result #{2561}) | 
#{B6} (insert tail result #{2562}) | 
#{B7} (insert tail result #{2556}) | 
#{B8} (insert tail result #{2555}) | 
#{B9} (insert tail result #{2563}) | 
#{BA} (insert tail result #{2551}) | 
#{BB} (insert tail result #{2557}) | 
#{BC} (insert tail result #{255D}) | 
#{BD} (insert tail result #{255C}) | 
#{BE} (insert tail result #{255B}) | 
#{BF} (insert tail result #{2510}) | 
#{C0} (insert tail result #{2514}) | 
#{C1} (insert tail result #{2534}) | 
#{C2} (insert tail result #{252C}) | 
#{C3} (insert tail result #{251C}) | 
#{C4} (insert tail result #{2500}) | 
#{C5} (insert tail result #{253C}) | 
#{C6} (insert tail result #{255E}) | 
#{C7} (insert tail result #{255F}) | 
#{C8} (insert tail result #{255A}) | 
#{C9} (insert tail result #{2554}) | 
#{CA} (insert tail result #{2569}) | 
#{CB} (insert tail result #{2566}) | 
#{CC} (insert tail result #{2560}) | 
#{CD} (insert tail result #{2550}) | 
#{CE} (insert tail result #{256C}) | 
#{CF} (insert tail result #{2567}) | 
#{D0} (insert tail result #{2568}) | 
#{D1} (insert tail result #{2564}) | 
#{D2} (insert tail result #{2565}) | 
#{D3} (insert tail result #{2559}) | 
#{D4} (insert tail result #{2558}) | 
#{D5} (insert tail result #{2552}) | 
#{D6} (insert tail result #{2553}) | 
#{D7} (insert tail result #{256B}) | 
#{D8} (insert tail result #{256A}) | 
#{D9} (insert tail result #{2518}) | 
#{DA} (insert tail result #{250C}) | 
#{DB} (insert tail result #{2588}) | 
#{DC} (insert tail result #{2584}) | 
#{DD} (insert tail result #{258C}) | 
#{DE} (insert tail result #{2590}) | 
#{DF} (insert tail result #{2580}) | 
#{E0} (insert tail result #{03B1}) | 
#{E1} (insert tail result #{00DF}) | 
#{E2} (insert tail result #{0393}) | 
#{E3} (insert tail result #{03C0}) | 
#{E4} (insert tail result #{03A3}) | 
#{E5} (insert tail result #{03C3}) | 
#{E6} (insert tail result #{00B5}) | 
#{E7} (insert tail result #{03C4}) | 
#{E8} (insert tail result #{03A6}) | 
#{E9} (insert tail result #{0398}) | 
#{EA} (insert tail result #{03A9}) | 
#{EB} (insert tail result #{03B4}) | 
#{EC} (insert tail result #{221E}) | 
#{ED} (insert tail result #{03C6}) | 
#{EE} (insert tail result #{03B5}) | 
#{EF} (insert tail result #{2229}) | 
#{F0} (insert tail result #{2261}) | 
#{F1} (insert tail result #{00B1}) | 
#{F2} (insert tail result #{2265}) | 
#{F3} (insert tail result #{2264}) | 
#{F4} (insert tail result #{2320}) | 
#{F5} (insert tail result #{2321}) | 
#{F6} (insert tail result #{00F7}) | 
#{F7} (insert tail result #{2248}) | 
#{F8} (insert tail result #{00B0}) | 
#{F9} (insert tail result #{00B7}) | 
#{FA} (insert tail result #{2022}) | 
#{FB} (insert tail result #{221A}) | 
#{FC} (insert tail result #{207F}) | 
#{FD} (insert tail result #{00B2}) | 
#{FE} (insert tail result #{25A0}) | 
#{FF} (insert tail result #{00A0}) | 
copy c 1 skip (insert tail result join #{00} c)
]