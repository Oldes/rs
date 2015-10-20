; ISO-8859-6 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO-8859-6
any [
#{AC} (insert tail result #{060C}) | 
#{BB} (insert tail result #{061B}) | 
#{BF} (insert tail result #{061F}) | 
#{C1} (insert tail result #{0621}) | 
#{C2} (insert tail result #{0622}) | 
#{C3} (insert tail result #{0623}) | 
#{C4} (insert tail result #{0624}) | 
#{C5} (insert tail result #{0625}) | 
#{C6} (insert tail result #{0626}) | 
#{C7} (insert tail result #{0627}) | 
#{C8} (insert tail result #{0628}) | 
#{C9} (insert tail result #{0629}) | 
#{CA} (insert tail result #{062A}) | 
#{CB} (insert tail result #{062B}) | 
#{CC} (insert tail result #{062C}) | 
#{CD} (insert tail result #{062D}) | 
#{CE} (insert tail result #{062E}) | 
#{CF} (insert tail result #{062F}) | 
#{D0} (insert tail result #{0630}) | 
#{D1} (insert tail result #{0631}) | 
#{D2} (insert tail result #{0632}) | 
#{D3} (insert tail result #{0633}) | 
#{D4} (insert tail result #{0634}) | 
#{D5} (insert tail result #{0635}) | 
#{D6} (insert tail result #{0636}) | 
#{D7} (insert tail result #{0637}) | 
#{D8} (insert tail result #{0638}) | 
#{D9} (insert tail result #{0639}) | 
#{DA} (insert tail result #{063A}) | 
#{E0} (insert tail result #{0640}) | 
#{E1} (insert tail result #{0641}) | 
#{E2} (insert tail result #{0642}) | 
#{E3} (insert tail result #{0643}) | 
#{E4} (insert tail result #{0644}) | 
#{E5} (insert tail result #{0645}) | 
#{E6} (insert tail result #{0646}) | 
#{E7} (insert tail result #{0647}) | 
#{E8} (insert tail result #{0648}) | 
#{E9} (insert tail result #{0649}) | 
#{EA} (insert tail result #{064A}) | 
#{EB} (insert tail result #{064B}) | 
#{EC} (insert tail result #{064C}) | 
#{ED} (insert tail result #{064D}) | 
#{EE} (insert tail result #{064E}) | 
#{EF} (insert tail result #{064F}) | 
#{F0} (insert tail result #{0650}) | 
#{F1} (insert tail result #{0651}) | 
#{F2} (insert tail result #{0652}) | 
copy c 1 skip (insert tail result join #{00} c)
]