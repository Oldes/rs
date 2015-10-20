; ISO_6937-2-25 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO_6937-2-25
any [
#{24} (insert tail result #{00A4}) | 
#{AA} (insert tail result #{201C}) | 
#{AC} (insert tail result #{2190}) | 
#{AD} (insert tail result #{2191}) | 
#{AE} (insert tail result #{2192}) | 
#{AF} (insert tail result #{2193}) | 
#{BA} (insert tail result #{201D}) | 
#{D4} (insert tail result #{2122}) | 
#{D5} (insert tail result #{266A}) | 
#{DC} (insert tail result #{215B}) | 
#{DD} (insert tail result #{215C}) | 
#{DE} (insert tail result #{215D}) | 
#{DF} (insert tail result #{215E}) | 
#{E0} (insert tail result #{2126}) | 
#{E6} (insert tail result #{0132}) | 
#{E7} (insert tail result #{013F}) | 
#{EA} (insert tail result #{0152}) | 
#{EC} (insert tail result #{0174}) | 
#{ED} (insert tail result #{0176}) | 
#{EE} (insert tail result #{0178}) | 
#{EF} (insert tail result #{0149}) | 
#{F6} (insert tail result #{0133}) | 
#{F7} (insert tail result #{0140}) | 
#{FA} (insert tail result #{0153}) | 
#{FC} (insert tail result #{0175}) | 
#{FD} (insert tail result #{0177}) | 
copy c 1 skip (insert tail result join #{00} c)
]