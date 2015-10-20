; ISO_8859-1 UCS-2 decoding rule
;  source: ftp://dkuug.dk/i18n/charmaps/ISO_8859-1
; created: 13-Oct-2003/10:22:23+2:00
any [
#{00} copy c 1 skip (insert tail result c) | 
copy c 2 skip (insert tail result c print rejoin [{!!! Unknown UCS-2 octet: } mold c])
]