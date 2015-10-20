; ISO-8859-15 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO-8859-15
any [
#{A4} (insert tail result #{20AC}) | 
#{A6} (insert tail result #{0160}) | 
#{A8} (insert tail result #{0161}) | 
#{B4} (insert tail result #{017D}) | 
#{B8} (insert tail result #{017E}) | 
#{BC} (insert tail result #{0152}) | 
#{BD} (insert tail result #{0153}) | 
#{BE} (insert tail result #{0178}) | 
copy c 1 skip (insert tail result join #{00} c)
]