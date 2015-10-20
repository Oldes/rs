; ISO-8859-3 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO-8859-3
any [
#{A1} (insert tail result #{0126}) | 
#{A2} (insert tail result #{02D8}) | 
#{A6} (insert tail result #{0124}) | 
#{A9} (insert tail result #{0130}) | 
#{AA} (insert tail result #{015E}) | 
#{AB} (insert tail result #{011E}) | 
#{AC} (insert tail result #{0134}) | 
#{AF} (insert tail result #{017B}) | 
#{B1} (insert tail result #{0127}) | 
#{B6} (insert tail result #{0125}) | 
#{B9} (insert tail result #{0131}) | 
#{BA} (insert tail result #{015F}) | 
#{BB} (insert tail result #{011F}) | 
#{BC} (insert tail result #{0135}) | 
#{BF} (insert tail result #{017C}) | 
#{C5} (insert tail result #{010A}) | 
#{C6} (insert tail result #{0108}) | 
#{D5} (insert tail result #{0120}) | 
#{D8} (insert tail result #{011C}) | 
#{DD} (insert tail result #{016C}) | 
#{DE} (insert tail result #{015C}) | 
#{E5} (insert tail result #{010B}) | 
#{E6} (insert tail result #{0109}) | 
#{F5} (insert tail result #{0121}) | 
#{F8} (insert tail result #{011D}) | 
#{FD} (insert tail result #{016D}) | 
#{FE} (insert tail result #{015D}) | 
#{FF} (insert tail result #{02D9}) | 
copy c 1 skip (insert tail result join #{00} c)
]