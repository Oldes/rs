; CP1256 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/CP1256
any [
#{80} (insert tail result #{060C}) | 
#{81} (insert tail result #{0660}) | 
#{82} (insert tail result #{201A}) | 
#{83} (insert tail result #{0661}) | 
#{84} (insert tail result #{201E}) | 
#{85} (insert tail result #{2026}) | 
#{86} (insert tail result #{2020}) | 
#{87} (insert tail result #{2021}) | 
#{88} (insert tail result #{0662}) | 
#{89} (insert tail result #{0663}) | 
#{8A} (insert tail result #{0664}) | 
#{8B} (insert tail result #{2039}) | 
#{8C} (insert tail result #{0665}) | 
#{8D} (insert tail result #{0666}) | 
#{8E} (insert tail result #{0667}) | 
#{8F} (insert tail result #{0668}) | 
#{90} (insert tail result #{0669}) | 
#{91} (insert tail result #{2018}) | 
#{92} (insert tail result #{2019}) | 
#{93} (insert tail result #{201C}) | 
#{94} (insert tail result #{201D}) | 
#{95} (insert tail result #{2022}) | 
#{96} (insert tail result #{2013}) | 
#{97} (insert tail result #{2014}) | 
#{98} (insert tail result #{061B}) | 
#{99} (insert tail result #{2122}) | 
#{9A} (insert tail result #{061F}) | 
#{9B} (insert tail result #{203A}) | 
#{9C} (insert tail result #{0621}) | 
#{9D} (insert tail result #{0622}) | 
#{9E} (insert tail result #{0623}) | 
#{9F} (insert tail result #{0178}) | 
#{A1} (insert tail result #{0624}) | 
#{A2} (insert tail result #{0625}) | 
#{A5} (insert tail result #{0626}) | 
#{A8} (insert tail result #{0627}) | 
#{AA} (insert tail result #{0628}) | 
#{AF} (insert tail result #{067E}) | 
#{B2} (insert tail result #{0629}) | 
#{B3} (insert tail result #{062A}) | 
#{B4} (insert tail result #{062B}) | 
#{B8} (insert tail result #{062C}) | 
#{B9} (insert tail result #{0686}) | 
#{BA} (insert tail result #{062D}) | 
#{BC} (insert tail result #{062E}) | 
#{BD} (insert tail result #{062F}) | 
#{BE} (insert tail result #{0630}) | 
#{BF} (insert tail result #{0631}) | 
#{C1} (insert tail result #{0632}) | 
#{C3} (insert tail result #{0698}) | 
#{C4} (insert tail result #{0633}) | 
#{C5} (insert tail result #{0634}) | 
#{C6} (insert tail result #{0635}) | 
#{CC} (insert tail result #{0636}) | 
#{CD} (insert tail result #{0637}) | 
#{D0} (insert tail result #{3113}) | 
#{D1} (insert tail result #{0639}) | 
#{D2} (insert tail result #{063A}) | 
#{D3} (insert tail result #{0640}) | 
#{D5} (insert tail result #{0641}) | 
#{D6} (insert tail result #{0642}) | 
#{D8} (insert tail result #{0643}) | 
#{DA} (insert tail result #{06AF}) | 
#{DD} (insert tail result #{0644}) | 
#{DE} (insert tail result #{0645}) | 
#{DF} (insert tail result #{0646}) | 
#{E1} (insert tail result #{0647}) | 
#{E3} (insert tail result #{0681}) | 
#{E4} (insert tail result #{0648}) | 
#{E5} (insert tail result #{0649}) | 
#{E6} (insert tail result #{064A}) | 
#{EC} (insert tail result #{064B}) | 
#{ED} (insert tail result #{064C}) | 
#{F0} (insert tail result #{064D}) | 
#{F1} (insert tail result #{064E}) | 
#{F2} (insert tail result #{064F}) | 
#{F3} (insert tail result #{0650}) | 
#{F5} (insert tail result #{0651}) | 
#{F6} (insert tail result #{0652}) | 
#{FD} (insert tail result #{200E}) | 
#{FE} (insert tail result #{200F}) | 
copy c 1 skip (insert tail result join #{00} c)
]