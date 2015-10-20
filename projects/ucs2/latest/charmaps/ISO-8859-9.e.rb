; ISO-8859-9 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO-8859-9
any [
#{D0} (insert tail result #{011E}) | 
#{DD} (insert tail result #{0130}) | 
#{DE} (insert tail result #{015E}) | 
#{F0} (insert tail result #{011F}) | 
#{FD} (insert tail result #{0131}) | 
#{FE} (insert tail result #{015F}) | 
copy c 1 skip (insert tail result join #{00} c)
]