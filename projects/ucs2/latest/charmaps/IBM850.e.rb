; IBM850 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/IBM850
any [
#{80} (insert tail result #{00C7}) | 
#{81} (insert tail result #{00FC}) | 
#{82} (insert tail result #{00E9}) | 
#{83} (insert tail result #{00E2}) | 
#{84} (insert tail result #{00E4}) | 
#{85} (insert tail result #{00E0}) | 
#{86} (insert tail result #{00E5}) | 
#{87} (insert tail result #{00E7}) | 
#{88} (insert tail result #{00EA}) | 
#{89} (insert tail result #{00EB}) | 
#{8A} (insert tail result #{00E8}) | 
#{8B} (insert tail result #{00EF}) | 
#{8C} (insert tail result #{00EE}) | 
#{8D} (insert tail result #{00EC}) | 
#{8E} (insert tail result #{00C4}) | 
#{8F} (insert tail result #{00C5}) | 
#{90} (insert tail result #{00C9}) | 
#{91} (insert tail result #{00E6}) | 
#{92} (insert tail result #{00C6}) | 
#{93} (insert tail result #{00F4}) | 
#{94} (insert tail result #{00F6}) | 
#{95} (insert tail result #{00F2}) | 
#{96} (insert tail result #{00FB}) | 
#{97} (insert tail result #{00F9}) | 
#{98} (insert tail result #{00FF}) | 
#{99} (insert tail result #{00D6}) | 
#{9A} (insert tail result #{00DC}) | 
#{9B} (insert tail result #{00F8}) | 
#{9C} (insert tail result #{00A3}) | 
#{9D} (insert tail result #{00D8}) | 
#{9E} (insert tail result #{00D7}) | 
#{9F} (insert tail result #{0192}) | 
#{A0} (insert tail result #{00E1}) | 
#{A1} (insert tail result #{00ED}) | 
#{A2} (insert tail result #{00F3}) | 
#{A3} (insert tail result #{00FA}) | 
#{A4} (insert tail result #{00F1}) | 
#{A5} (insert tail result #{00D1}) | 
#{A6} (insert tail result #{00AA}) | 
#{A7} (insert tail result #{00BA}) | 
#{A8} (insert tail result #{00BF}) | 
#{A9} (insert tail result #{00AE}) | 
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
#{B5} (insert tail result #{00C1}) | 
#{B6} (insert tail result #{00C2}) | 
#{B7} (insert tail result #{00C0}) | 
#{B8} (insert tail result #{00A9}) | 
#{B9} (insert tail result #{2563}) | 
#{BA} (insert tail result #{2551}) | 
#{BB} (insert tail result #{2557}) | 
#{BC} (insert tail result #{255D}) | 
#{BD} (insert tail result #{00A2}) | 
#{BE} (insert tail result #{00A5}) | 
#{BF} (insert tail result #{2510}) | 
#{C0} (insert tail result #{2514}) | 
#{C1} (insert tail result #{2534}) | 
#{C2} (insert tail result #{252C}) | 
#{C3} (insert tail result #{251C}) | 
#{C4} (insert tail result #{2500}) | 
#{C5} (insert tail result #{253C}) | 
#{C6} (insert tail result #{00E3}) | 
#{C7} (insert tail result #{00C3}) | 
#{C8} (insert tail result #{255A}) | 
#{C9} (insert tail result #{2554}) | 
#{CA} (insert tail result #{2569}) | 
#{CB} (insert tail result #{2566}) | 
#{CC} (insert tail result #{2560}) | 
#{CD} (insert tail result #{2550}) | 
#{CE} (insert tail result #{256C}) | 
#{CF} (insert tail result #{00A4}) | 
#{D0} (insert tail result #{00F0}) | 
#{D1} (insert tail result #{00D0}) | 
#{D2} (insert tail result #{00CA}) | 
#{D3} (insert tail result #{00CB}) | 
#{D4} (insert tail result #{00C8}) | 
#{D5} (insert tail result #{0131}) | 
#{D6} (insert tail result #{00CD}) | 
#{D7} (insert tail result #{00CE}) | 
#{D8} (insert tail result #{00CF}) | 
#{D9} (insert tail result #{2518}) | 
#{DA} (insert tail result #{250C}) | 
#{DB} (insert tail result #{2588}) | 
#{DC} (insert tail result #{2584}) | 
#{DD} (insert tail result #{00A6}) | 
#{DE} (insert tail result #{00CC}) | 
#{DF} (insert tail result #{2580}) | 
#{E0} (insert tail result #{00D3}) | 
#{E1} (insert tail result #{00DF}) | 
#{E2} (insert tail result #{00D4}) | 
#{E3} (insert tail result #{00D2}) | 
#{E4} (insert tail result #{00F5}) | 
#{E5} (insert tail result #{00D5}) | 
#{E6} (insert tail result #{00B5}) | 
#{E7} (insert tail result #{00FE}) | 
#{E8} (insert tail result #{00DE}) | 
#{E9} (insert tail result #{00DA}) | 
#{EA} (insert tail result #{00DB}) | 
#{EB} (insert tail result #{00D9}) | 
#{EC} (insert tail result #{00FD}) | 
#{ED} (insert tail result #{00DD}) | 
#{EE} (insert tail result #{00AF}) | 
#{EF} (insert tail result #{00B4}) | 
#{F0} (insert tail result #{00AD}) | 
#{F1} (insert tail result #{00B1}) | 
#{F2} (insert tail result #{2017}) | 
#{F3} (insert tail result #{00BE}) | 
#{F4} (insert tail result #{00B6}) | 
#{F5} (insert tail result #{00A7}) | 
#{F6} (insert tail result #{00F7}) | 
#{F7} (insert tail result #{00B8}) | 
#{F8} (insert tail result #{00B0}) | 
#{F9} (insert tail result #{00A8}) | 
#{FA} (insert tail result #{00B7}) | 
#{FB} (insert tail result #{00B9}) | 
#{FC} (insert tail result #{00B3}) | 
#{FD} (insert tail result #{00B2}) | 
#{FE} (insert tail result #{25A0}) | 
#{FF} (insert tail result #{00A0}) | 
copy c 1 skip (insert tail result join #{00} c)
]