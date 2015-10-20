; CP1255 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/CP1255
any [
#{82} (insert tail result #{201A}) | 
#{83} (insert tail result #{0192}) | 
#{84} (insert tail result #{201E}) | 
#{85} (insert tail result #{2026}) | 
#{86} (insert tail result #{2020}) | 
#{87} (insert tail result #{2021}) | 
#{89} (insert tail result #{2030}) | 
#{8B} (insert tail result #{2039}) | 
#{91} (insert tail result #{2018}) | 
#{92} (insert tail result #{2019}) | 
#{93} (insert tail result #{201C}) | 
#{94} (insert tail result #{201D}) | 
#{95} (insert tail result #{2022}) | 
#{96} (insert tail result #{2013}) | 
#{97} (insert tail result #{2014}) | 
#{99} (insert tail result #{2122}) | 
#{9B} (insert tail result #{203A}) | 
#{AA} (insert tail result #{00D7}) | 
#{AF} (insert tail result #{203E}) | 
#{BA} (insert tail result #{00F7}) | 
#{DF} (insert tail result #{2017}) | 
#{E0} (insert tail result #{05D0}) | 
#{E1} (insert tail result #{05D1}) | 
#{E2} (insert tail result #{05D2}) | 
#{E3} (insert tail result #{05D3}) | 
#{E4} (insert tail result #{05D4}) | 
#{E5} (insert tail result #{05D5}) | 
#{E6} (insert tail result #{05D6}) | 
#{E7} (insert tail result #{05D7}) | 
#{E8} (insert tail result #{05D8}) | 
#{E9} (insert tail result #{05D9}) | 
#{EA} (insert tail result #{05DA}) | 
#{EB} (insert tail result #{05DB}) | 
#{EC} (insert tail result #{05DC}) | 
#{ED} (insert tail result #{05DD}) | 
#{EE} (insert tail result #{05DE}) | 
#{EF} (insert tail result #{05DF}) | 
#{F0} (insert tail result #{05E0}) | 
#{F1} (insert tail result #{05E1}) | 
#{F2} (insert tail result #{05E2}) | 
#{F3} (insert tail result #{05E3}) | 
#{F4} (insert tail result #{05E4}) | 
#{F5} (insert tail result #{05E5}) | 
#{F6} (insert tail result #{05E6}) | 
#{F7} (insert tail result #{05E7}) | 
#{F8} (insert tail result #{05E8}) | 
#{F9} (insert tail result #{05E9}) | 
#{FA} (insert tail result #{05EA}) | 
#{FD} (insert tail result #{200E}) | 
#{FE} (insert tail result #{200F}) | 
copy c 1 skip (insert tail result join #{00} c)
]