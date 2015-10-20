; SAMI UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/SAMI
any [
#{A0} (insert tail result #{00B4}) | 
#{B0} (insert tail result #{02BB}) | 
#{C0} (insert tail result #{0102}) | 
#{C1} (insert tail result #{00C0}) | 
#{C2} (insert tail result #{01DE}) | 
#{C3} (insert tail result #{01E0}) | 
#{C4} (insert tail result #{01E2}) | 
#{C5} (insert tail result #{0114}) | 
#{C6} (insert tail result #{00C8}) | 
#{C7} (insert tail result #{01E4}) | 
#{C8} (insert tail result #{01E6}) | 
#{C9} (insert tail result #{01E8}) | 
#{CA} (insert tail result #{014E}) | 
#{CB} (insert tail result #{00D2}) | 
#{CC} (insert tail result #{01EA}) | 
#{CD} (insert tail result #{01EC}) | 
#{CE} (insert tail result #{01B7}) | 
#{CF} (insert tail result #{01EE}) | 
#{E0} (insert tail result #{0103}) | 
#{E1} (insert tail result #{00E0}) | 
#{E2} (insert tail result #{01DF}) | 
#{E3} (insert tail result #{01E1}) | 
#{E4} (insert tail result #{01E3}) | 
#{E5} (insert tail result #{0115}) | 
#{E6} (insert tail result #{00E8}) | 
#{E7} (insert tail result #{01E5}) | 
#{E8} (insert tail result #{01E7}) | 
#{EA} (insert tail result #{014F}) | 
#{EB} (insert tail result #{00F2}) | 
#{EC} (insert tail result #{01EB}) | 
#{EE} (insert tail result #{0292}) | 
copy c 1 skip (insert tail result join #{00} c)
]