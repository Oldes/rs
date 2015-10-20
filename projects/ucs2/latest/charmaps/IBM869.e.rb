; IBM869 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/IBM869
any [
#{88} (insert tail result #{00B7}) | 
#{89} (insert tail result #{00AC}) | 
#{8A} (insert tail result #{00A6}) | 
#{8B} (insert tail result #{201B}) | 
#{8C} (insert tail result #{2019}) | 
#{8D} (insert tail result #{0388}) | 
#{8E} (insert tail result #{2014}) | 
#{8F} (insert tail result #{0389}) | 
#{90} (insert tail result #{038A}) | 
#{91} (insert tail result #{03AA}) | 
#{92} (insert tail result #{038C}) | 
#{95} (insert tail result #{038E}) | 
#{96} (insert tail result #{03AB}) | 
#{97} (insert tail result #{00A9}) | 
#{98} (insert tail result #{038F}) | 
#{99} (insert tail result #{00B2}) | 
#{9A} (insert tail result #{00B3}) | 
#{9B} (insert tail result #{03AC}) | 
#{9C} (insert tail result #{00A3}) | 
#{9D} (insert tail result #{03AD}) | 
#{9E} (insert tail result #{03AE}) | 
#{9F} (insert tail result #{03AF}) | 
#{A0} (insert tail result #{03CA}) | 
#{A1} (insert tail result #{0390}) | 
#{A2} (insert tail result #{03CC}) | 
#{A3} (insert tail result #{03CD}) | 
#{A4} (insert tail result #{0391}) | 
#{A5} (insert tail result #{0392}) | 
#{A6} (insert tail result #{0393}) | 
#{A7} (insert tail result #{0394}) | 
#{A8} (insert tail result #{0395}) | 
#{A9} (insert tail result #{0396}) | 
#{AA} (insert tail result #{0397}) | 
#{AB} (insert tail result #{00BD}) | 
#{AC} (insert tail result #{0398}) | 
#{AD} (insert tail result #{0399}) | 
#{AE} (insert tail result #{00AB}) | 
#{AF} (insert tail result #{00BB}) | 
#{B0} (insert tail result #{2591}) | 
#{B1} (insert tail result #{2592}) | 
#{B2} (insert tail result #{2593}) | 
#{B3} (insert tail result #{2502}) | 
#{B4} (insert tail result #{2524}) | 
#{B5} (insert tail result #{039A}) | 
#{B6} (insert tail result #{039B}) | 
#{B7} (insert tail result #{039C}) | 
#{B8} (insert tail result #{039D}) | 
#{B9} (insert tail result #{2563}) | 
#{BA} (insert tail result #{2551}) | 
#{BB} (insert tail result #{2557}) | 
#{BC} (insert tail result #{255D}) | 
#{BD} (insert tail result #{039E}) | 
#{BE} (insert tail result #{039F}) | 
#{BF} (insert tail result #{2510}) | 
#{C0} (insert tail result #{2514}) | 
#{C1} (insert tail result #{2534}) | 
#{C2} (insert tail result #{252C}) | 
#{C3} (insert tail result #{251C}) | 
#{C4} (insert tail result #{2500}) | 
#{C5} (insert tail result #{253C}) | 
#{C6} (insert tail result #{03A0}) | 
#{C7} (insert tail result #{03A1}) | 
#{C8} (insert tail result #{255A}) | 
#{C9} (insert tail result #{2554}) | 
#{CA} (insert tail result #{2569}) | 
#{CB} (insert tail result #{2566}) | 
#{CC} (insert tail result #{2560}) | 
#{CD} (insert tail result #{2550}) | 
#{CE} (insert tail result #{256C}) | 
#{CF} (insert tail result #{03A3}) | 
#{D0} (insert tail result #{03A4}) | 
#{D1} (insert tail result #{03A5}) | 
#{D2} (insert tail result #{03A6}) | 
#{D3} (insert tail result #{03A7}) | 
#{D4} (insert tail result #{03A8}) | 
#{D5} (insert tail result #{03A9}) | 
#{D6} (insert tail result #{03B1}) | 
#{D7} (insert tail result #{03B2}) | 
#{D8} (insert tail result #{03B3}) | 
#{D9} (insert tail result #{2518}) | 
#{DA} (insert tail result #{250C}) | 
#{DB} (insert tail result #{2588}) | 
#{DC} (insert tail result #{2584}) | 
#{DD} (insert tail result #{03B4}) | 
#{DE} (insert tail result #{03B5}) | 
#{DF} (insert tail result #{2580}) | 
#{E0} (insert tail result #{03B6}) | 
#{E1} (insert tail result #{03B7}) | 
#{E2} (insert tail result #{03B8}) | 
#{E3} (insert tail result #{03B9}) | 
#{E4} (insert tail result #{03BA}) | 
#{E5} (insert tail result #{03BB}) | 
#{E6} (insert tail result #{03BC}) | 
#{E7} (insert tail result #{03BD}) | 
#{E8} (insert tail result #{03BE}) | 
#{E9} (insert tail result #{03BF}) | 
#{EA} (insert tail result #{03C0}) | 
#{EB} (insert tail result #{03C1}) | 
#{EC} (insert tail result #{03C3}) | 
#{ED} (insert tail result #{03C2}) | 
#{EE} (insert tail result #{03C4}) | 
#{EF} (insert tail result #{00B4}) | 
#{F0} (insert tail result #{00AD}) | 
#{F1} (insert tail result #{00B1}) | 
#{F2} (insert tail result #{03C5}) | 
#{F3} (insert tail result #{03C6}) | 
#{F4} (insert tail result #{03C7}) | 
#{F5} (insert tail result #{00A7}) | 
#{F6} (insert tail result #{03C8}) | 
#{F7} (insert tail result #{0385}) | 
#{F8} (insert tail result #{00B0}) | 
#{F9} (insert tail result #{00A8}) | 
#{FA} (insert tail result #{03C9}) | 
#{FB} (insert tail result #{03CB}) | 
#{FC} (insert tail result #{03B0}) | 
#{FD} (insert tail result #{03CE}) | 
#{FE} (insert tail result #{25A0}) | 
#{FF} (insert tail result #{00A0}) | 
copy c 1 skip (insert tail result join #{00} c)
]