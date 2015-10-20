; DEC-MCS UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/DEC-MCS
any [
#{A8} (insert tail result #{00A4}) | 
#{D7} (insert tail result #{0152}) | 
#{DD} (insert tail result #{0178}) | 
#{F7} (insert tail result #{0153}) | 
#{FD} (insert tail result #{00FF}) | 
copy c 1 skip (insert tail result join #{00} c)
]