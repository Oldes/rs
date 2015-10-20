; IBM852 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/IBM852
any [
#{80} (insert tail result #{00C7}) | 
#{81} (insert tail result #{00FC}) | 
#{82} (insert tail result #{00E9}) | 
#{83} (insert tail result #{00E2}) | 
#{84} (insert tail result #{00E4}) | 
#{85} (insert tail result #{016F}) | 
#{86} (insert tail result #{0107}) | 
#{87} (insert tail result #{00E7}) | 
#{88} (insert tail result #{0142}) | 
#{89} (insert tail result #{00EB}) | 
#{8A} (insert tail result #{0150}) | 
#{8B} (insert tail result #{0151}) | 
#{8C} (insert tail result #{00EE}) | 
#{8D} (insert tail result #{0179}) | 
#{8E} (insert tail result #{00C4}) | 
#{8F} (insert tail result #{0106}) | 
#{90} (insert tail result #{00C9}) | 
#{91} (insert tail result #{0139}) | 
#{92} (insert tail result #{013A}) | 
#{93} (insert tail result #{00F4}) | 
#{94} (insert tail result #{00F6}) | 
#{95} (insert tail result #{013D}) | 
#{96} (insert tail result #{013E}) | 
#{97} (insert tail result #{015A}) | 
#{98} (insert tail result #{015B}) | 
#{99} (insert tail result #{00D6}) | 
#{9A} (insert tail result #{00DC}) | 
#{9B} (insert tail result #{0164}) | 
#{9C} (insert tail result #{0165}) | 
#{9D} (insert tail result #{0141}) | 
#{9E} (insert tail result #{00D7}) | 
#{9F} (insert tail result #{010D}) | 
#{A0} (insert tail result #{00E1}) | 
#{A1} (insert tail result #{00ED}) | 
#{A2} (insert tail result #{00F3}) | 
#{A3} (insert tail result #{00FA}) | 
#{A4} (insert tail result #{0104}) | 
#{A5} (insert tail result #{0105}) | 
#{A6} (insert tail result #{017D}) | 
#{A7} (insert tail result #{017E}) | 
#{A8} (insert tail result #{0118}) | 
#{A9} (insert tail result #{0119}) | 
#{AA} (insert tail result #{00AC}) | 
#{AB} (insert tail result #{017A}) | 
#{AC} (insert tail result #{010C}) | 
#{AD} (insert tail result #{015F}) | 
#{AE} (insert tail result #{00AB}) | 
#{AF} (insert tail result #{00BB}) | 
#{B0} (insert tail result #{2591}) | 
#{B1} (insert tail result #{2592}) | 
#{B2} (insert tail result #{2593}) | 
#{B3} (insert tail result #{2502}) | 
#{B4} (insert tail result #{2524}) | 
#{B5} (insert tail result #{00C1}) | 
#{B6} (insert tail result #{00C2}) | 
#{B7} (insert tail result #{011A}) | 
#{B8} (insert tail result #{015E}) | 
#{B9} (insert tail result #{2563}) | 
#{BA} (insert tail result #{2551}) | 
#{BB} (insert tail result #{2557}) | 
#{BC} (insert tail result #{255D}) | 
#{BD} (insert tail result #{017B}) | 
#{BE} (insert tail result #{017C}) | 
#{BF} (insert tail result #{2510}) | 
#{C0} (insert tail result #{2514}) | 
#{C1} (insert tail result #{2534}) | 
#{C2} (insert tail result #{252C}) | 
#{C3} (insert tail result #{251C}) | 
#{C4} (insert tail result #{2500}) | 
#{C5} (insert tail result #{253C}) | 
#{C6} (insert tail result #{0102}) | 
#{C7} (insert tail result #{0103}) | 
#{C8} (insert tail result #{255A}) | 
#{C9} (insert tail result #{2554}) | 
#{CA} (insert tail result #{2569}) | 
#{CB} (insert tail result #{2566}) | 
#{CC} (insert tail result #{2560}) | 
#{CD} (insert tail result #{2550}) | 
#{CE} (insert tail result #{256C}) | 
#{CF} (insert tail result #{00A4}) | 
#{D0} (insert tail result #{0111}) | 
#{D1} (insert tail result #{0110}) | 
#{D2} (insert tail result #{010E}) | 
#{D3} (insert tail result #{00CB}) | 
#{D4} (insert tail result #{010F}) | 
#{D5} (insert tail result #{0147}) | 
#{D6} (insert tail result #{00CD}) | 
#{D7} (insert tail result #{00CE}) | 
#{D8} (insert tail result #{011B}) | 
#{D9} (insert tail result #{2518}) | 
#{DA} (insert tail result #{250C}) | 
#{DB} (insert tail result #{2588}) | 
#{DC} (insert tail result #{2584}) | 
#{DD} (insert tail result #{0162}) | 
#{DE} (insert tail result #{016E}) | 
#{DF} (insert tail result #{2580}) | 
#{E0} (insert tail result #{00D3}) | 
#{E1} (insert tail result #{00DF}) | 
#{E2} (insert tail result #{00D4}) | 
#{E3} (insert tail result #{0143}) | 
#{E4} (insert tail result #{0144}) | 
#{E5} (insert tail result #{0148}) | 
#{E6} (insert tail result #{0160}) | 
#{E7} (insert tail result #{0161}) | 
#{E8} (insert tail result #{0154}) | 
#{E9} (insert tail result #{00DA}) | 
#{EA} (insert tail result #{0155}) | 
#{EB} (insert tail result #{0170}) | 
#{EC} (insert tail result #{00FD}) | 
#{ED} (insert tail result #{00DD}) | 
#{EE} (insert tail result #{0163}) | 
#{EF} (insert tail result #{00B4}) | 
#{F0} (insert tail result #{00AD}) | 
#{F1} (insert tail result #{02DD}) | 
#{F2} (insert tail result #{02DB}) | 
#{F3} (insert tail result #{02C7}) | 
#{F4} (insert tail result #{02D8}) | 
#{F5} (insert tail result #{00A7}) | 
#{F6} (insert tail result #{00F7}) | 
#{F7} (insert tail result #{00B8}) | 
#{F8} (insert tail result #{00B0}) | 
#{F9} (insert tail result #{00A8}) | 
#{FA} (insert tail result #{02D9}) | 
#{FB} (insert tail result #{0171}) | 
#{FC} (insert tail result #{0158}) | 
#{FD} (insert tail result #{0159}) | 
#{FE} (insert tail result #{25A0}) | 
#{FF} (insert tail result #{00A0}) | 
copy c 1 skip (insert tail result join #{00} c)
]