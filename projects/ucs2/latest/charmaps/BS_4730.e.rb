; BS_4730 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/BS_4730
any [
#{23} (insert tail result #{00A3}) | 
#{7E} (insert tail result #{203E}) | 
copy c 1 skip (insert tail result join #{00} c)
]