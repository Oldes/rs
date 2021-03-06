; CP1257 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/CP1257
any [
#{82} (insert tail result #{201A}) | 
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
#{A8} (insert tail result #{00D8}) | 
#{AA} (insert tail result #{0156}) | 
#{AF} (insert tail result #{00C6}) | 
#{B8} (insert tail result #{00F8}) | 
#{BA} (insert tail result #{0157}) | 
#{BF} (insert tail result #{00E6}) | 
#{C0} (insert tail result #{0104}) | 
#{C1} (insert tail result #{012E}) | 
#{C2} (insert tail result #{0100}) | 
#{C3} (insert tail result #{0106}) | 
#{C6} (insert tail result #{0118}) | 
#{C7} (insert tail result #{0112}) | 
#{C8} (insert tail result #{010C}) | 
#{CA} (insert tail result #{0179}) | 
#{CB} (insert tail result #{0116}) | 
#{CC} (insert tail result #{0122}) | 
#{CD} (insert tail result #{0136}) | 
#{CE} (insert tail result #{012A}) | 
#{CF} (insert tail result #{013B}) | 
#{D0} (insert tail result #{0160}) | 
#{D1} (insert tail result #{0143}) | 
#{D2} (insert tail result #{0145}) | 
#{D4} (insert tail result #{014C}) | 
#{D8} (insert tail result #{0172}) | 
#{D9} (insert tail result #{0141}) | 
#{DA} (insert tail result #{015A}) | 
#{DB} (insert tail result #{016A}) | 
#{DD} (insert tail result #{017B}) | 
#{DE} (insert tail result #{017D}) | 
#{E0} (insert tail result #{0105}) | 
#{E1} (insert tail result #{012F}) | 
#{E2} (insert tail result #{0101}) | 
#{E3} (insert tail result #{0107}) | 
#{E6} (insert tail result #{0119}) | 
#{E7} (insert tail result #{0113}) | 
#{E8} (insert tail result #{010D}) | 
#{EA} (insert tail result #{017A}) | 
#{EB} (insert tail result #{0117}) | 
#{EC} (insert tail result #{0123}) | 
#{ED} (insert tail result #{0137}) | 
#{EE} (insert tail result #{012B}) | 
#{EF} (insert tail result #{013C}) | 
#{F0} (insert tail result #{0161}) | 
#{F1} (insert tail result #{0144}) | 
#{F2} (insert tail result #{0146}) | 
#{F4} (insert tail result #{014D}) | 
#{F8} (insert tail result #{0173}) | 
#{F9} (insert tail result #{0142}) | 
#{FA} (insert tail result #{015B}) | 
#{FB} (insert tail result #{016B}) | 
#{FD} (insert tail result #{017C}) | 
#{FE} (insert tail result #{017E}) | 
copy c 1 skip (insert tail result join #{00} c)
]