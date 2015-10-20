; ISO-8859-10 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO-8859-10
any [
#{A1} (insert tail result #{0104}) | 
#{A2} (insert tail result #{0112}) | 
#{A3} (insert tail result #{0122}) | 
#{A4} (insert tail result #{012A}) | 
#{A5} (insert tail result #{0128}) | 
#{A6} (insert tail result #{0136}) | 
#{A8} (insert tail result #{013B}) | 
#{A9} (insert tail result #{0110}) | 
#{AA} (insert tail result #{0160}) | 
#{AB} (insert tail result #{0166}) | 
#{AC} (insert tail result #{017D}) | 
#{AE} (insert tail result #{016A}) | 
#{AF} (insert tail result #{014A}) | 
#{B1} (insert tail result #{0105}) | 
#{B2} (insert tail result #{0113}) | 
#{B3} (insert tail result #{0123}) | 
#{B4} (insert tail result #{012B}) | 
#{B5} (insert tail result #{0129}) | 
#{B6} (insert tail result #{0137}) | 
#{B8} (insert tail result #{013C}) | 
#{B9} (insert tail result #{0111}) | 
#{BA} (insert tail result #{0161}) | 
#{BB} (insert tail result #{0167}) | 
#{BC} (insert tail result #{017E}) | 
#{BD} (insert tail result #{2014}) | 
#{BE} (insert tail result #{016B}) | 
#{BF} (insert tail result #{014B}) | 
#{C0} (insert tail result #{0100}) | 
#{C7} (insert tail result #{012E}) | 
#{C8} (insert tail result #{010C}) | 
#{CA} (insert tail result #{0118}) | 
#{CC} (insert tail result #{0116}) | 
#{D1} (insert tail result #{0145}) | 
#{D2} (insert tail result #{014C}) | 
#{D7} (insert tail result #{0168}) | 
#{D9} (insert tail result #{0172}) | 
#{E0} (insert tail result #{0101}) | 
#{E7} (insert tail result #{012F}) | 
#{E8} (insert tail result #{010D}) | 
#{EA} (insert tail result #{0119}) | 
#{EC} (insert tail result #{0117}) | 
#{F1} (insert tail result #{0146}) | 
#{F2} (insert tail result #{014D}) | 
#{F7} (insert tail result #{0169}) | 
#{F9} (insert tail result #{0173}) | 
#{FF} (insert tail result #{0138}) | 
copy c 1 skip (insert tail result join #{00} c)
]