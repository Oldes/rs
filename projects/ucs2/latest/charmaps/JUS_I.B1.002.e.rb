; JUS_I.B1.002 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/JUS_I.B1.002
any [
#{40} (insert tail result #{017D}) | 
#{5B} (insert tail result #{0160}) | 
#{5C} (insert tail result #{0110}) | 
#{5D} (insert tail result #{0106}) | 
#{5E} (insert tail result #{010C}) | 
#{60} (insert tail result #{017E}) | 
#{7B} (insert tail result #{0161}) | 
#{7C} (insert tail result #{0111}) | 
#{7D} (insert tail result #{0107}) | 
#{7E} (insert tail result #{010D}) | 
copy c 1 skip (insert tail result join #{00} c)
]