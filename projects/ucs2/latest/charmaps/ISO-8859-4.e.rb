; ISO-8859-4 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO-8859-4
any [
#{A1} (insert tail result #{0104}) | 
#{A2} (insert tail result #{0138}) | 
#{A3} (insert tail result #{0156}) | 
#{A5} (insert tail result #{0128}) | 
#{A6} (insert tail result #{013B}) | 
#{A9} (insert tail result #{0160}) | 
#{AA} (insert tail result #{0112}) | 
#{AB} (insert tail result #{0122}) | 
#{AC} (insert tail result #{0166}) | 
#{AE} (insert tail result #{017D}) | 
#{B1} (insert tail result #{0105}) | 
#{B2} (insert tail result #{02DB}) | 
#{B3} (insert tail result #{0157}) | 
#{B5} (insert tail result #{0129}) | 
#{B6} (insert tail result #{013C}) | 
#{B7} (insert tail result #{02C7}) | 
#{B9} (insert tail result #{0161}) | 
#{BA} (insert tail result #{0113}) | 
#{BB} (insert tail result #{0123}) | 
#{BC} (insert tail result #{0167}) | 
#{BD} (insert tail result #{014A}) | 
#{BE} (insert tail result #{017E}) | 
#{BF} (insert tail result #{014B}) | 
#{C0} (insert tail result #{0100}) | 
#{C7} (insert tail result #{012E}) | 
#{C8} (insert tail result #{010C}) | 
#{CA} (insert tail result #{0118}) | 
#{CC} (insert tail result #{0116}) | 
#{CF} (insert tail result #{012A}) | 
#{D0} (insert tail result #{0110}) | 
#{D1} (insert tail result #{0145}) | 
#{D2} (insert tail result #{014C}) | 
#{D3} (insert tail result #{0136}) | 
#{D9} (insert tail result #{0172}) | 
#{DD} (insert tail result #{0168}) | 
#{DE} (insert tail result #{016A}) | 
#{E0} (insert tail result #{0101}) | 
#{E7} (insert tail result #{012F}) | 
#{E8} (insert tail result #{010D}) | 
#{EA} (insert tail result #{0119}) | 
#{EC} (insert tail result #{0117}) | 
#{EF} (insert tail result #{012B}) | 
#{F0} (insert tail result #{0111}) | 
#{F1} (insert tail result #{0146}) | 
#{F2} (insert tail result #{014D}) | 
#{F3} (insert tail result #{0137}) | 
#{F9} (insert tail result #{0173}) | 
#{FD} (insert tail result #{0169}) | 
#{FE} (insert tail result #{016B}) | 
#{FF} (insert tail result #{02D9}) | 
copy c 1 skip (insert tail result join #{00} c)
]