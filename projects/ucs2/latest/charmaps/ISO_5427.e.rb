; ISO_5427 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO_5427
any [
#{24} (insert tail result #{00A4}) | 
#{40} (insert tail result #{044E}) | 
#{41} (insert tail result #{0430}) | 
#{42} (insert tail result #{0431}) | 
#{43} (insert tail result #{0446}) | 
#{44} (insert tail result #{0434}) | 
#{45} (insert tail result #{0435}) | 
#{46} (insert tail result #{0444}) | 
#{47} (insert tail result #{0433}) | 
#{48} (insert tail result #{0445}) | 
#{49} (insert tail result #{0438}) | 
#{4A} (insert tail result #{0439}) | 
#{4B} (insert tail result #{043A}) | 
#{4C} (insert tail result #{043B}) | 
#{4D} (insert tail result #{043C}) | 
#{4E} (insert tail result #{043D}) | 
#{4F} (insert tail result #{043E}) | 
#{50} (insert tail result #{043F}) | 
#{51} (insert tail result #{044F}) | 
#{52} (insert tail result #{0440}) | 
#{53} (insert tail result #{0441}) | 
#{54} (insert tail result #{0442}) | 
#{55} (insert tail result #{0443}) | 
#{56} (insert tail result #{0436}) | 
#{57} (insert tail result #{0432}) | 
#{58} (insert tail result #{044C}) | 
#{59} (insert tail result #{044B}) | 
#{5A} (insert tail result #{0437}) | 
#{5B} (insert tail result #{0448}) | 
#{5C} (insert tail result #{044D}) | 
#{5D} (insert tail result #{0449}) | 
#{5E} (insert tail result #{0447}) | 
#{5F} (insert tail result #{044A}) | 
#{60} (insert tail result #{042E}) | 
#{61} (insert tail result #{0410}) | 
#{62} (insert tail result #{0411}) | 
#{63} (insert tail result #{0426}) | 
#{64} (insert tail result #{0414}) | 
#{65} (insert tail result #{0415}) | 
#{66} (insert tail result #{0424}) | 
#{67} (insert tail result #{0413}) | 
#{68} (insert tail result #{0425}) | 
#{69} (insert tail result #{0418}) | 
#{6A} (insert tail result #{0419}) | 
#{6B} (insert tail result #{041A}) | 
#{6C} (insert tail result #{041B}) | 
#{6D} (insert tail result #{041C}) | 
#{6E} (insert tail result #{041D}) | 
#{6F} (insert tail result #{041E}) | 
#{70} (insert tail result #{041F}) | 
#{71} (insert tail result #{042F}) | 
#{72} (insert tail result #{0420}) | 
#{73} (insert tail result #{0421}) | 
#{74} (insert tail result #{0422}) | 
#{75} (insert tail result #{0423}) | 
#{76} (insert tail result #{0416}) | 
#{77} (insert tail result #{0412}) | 
#{78} (insert tail result #{042C}) | 
#{79} (insert tail result #{042B}) | 
#{7A} (insert tail result #{0417}) | 
#{7B} (insert tail result #{0428}) | 
#{7C} (insert tail result #{042D}) | 
#{7D} (insert tail result #{0429}) | 
#{7E} (insert tail result #{0427}) | 
copy c 1 skip (insert tail result join #{00} c)
]