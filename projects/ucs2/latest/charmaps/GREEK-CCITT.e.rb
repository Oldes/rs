; GREEK-CCITT UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/GREEK-CCITT
any [
#{24} (insert tail result #{00A4}) | 
#{41} (insert tail result #{0391}) | 
#{42} (insert tail result #{0392}) | 
#{43} (insert tail result #{0393}) | 
#{44} (insert tail result #{0394}) | 
#{45} (insert tail result #{0395}) | 
#{46} (insert tail result #{0396}) | 
#{47} (insert tail result #{0397}) | 
#{48} (insert tail result #{0398}) | 
#{49} (insert tail result #{0399}) | 
#{4A} (insert tail result #{039A}) | 
#{4B} (insert tail result #{039B}) | 
#{4C} (insert tail result #{039C}) | 
#{4D} (insert tail result #{039D}) | 
#{4E} (insert tail result #{039E}) | 
#{4F} (insert tail result #{039F}) | 
#{50} (insert tail result #{03A0}) | 
#{51} (insert tail result #{03A1}) | 
#{53} (insert tail result #{03A3}) | 
#{54} (insert tail result #{03A4}) | 
#{55} (insert tail result #{03A5}) | 
#{56} (insert tail result #{03A6}) | 
#{57} (insert tail result #{03A7}) | 
#{58} (insert tail result #{03A8}) | 
#{59} (insert tail result #{03A9}) | 
#{61} (insert tail result #{03B1}) | 
#{62} (insert tail result #{03B2}) | 
#{63} (insert tail result #{03B3}) | 
#{64} (insert tail result #{03B4}) | 
#{65} (insert tail result #{03B5}) | 
#{66} (insert tail result #{03B6}) | 
#{67} (insert tail result #{03B7}) | 
#{68} (insert tail result #{03B8}) | 
#{69} (insert tail result #{03B9}) | 
#{6A} (insert tail result #{03BA}) | 
#{6B} (insert tail result #{03BB}) | 
#{6C} (insert tail result #{03BC}) | 
#{6D} (insert tail result #{03BD}) | 
#{6E} (insert tail result #{03BE}) | 
#{6F} (insert tail result #{03BF}) | 
#{70} (insert tail result #{03C0}) | 
#{71} (insert tail result #{03C1}) | 
#{72} (insert tail result #{03C2}) | 
#{73} (insert tail result #{03C3}) | 
#{74} (insert tail result #{03C4}) | 
#{75} (insert tail result #{03C5}) | 
#{76} (insert tail result #{03C6}) | 
#{77} (insert tail result #{03C7}) | 
#{78} (insert tail result #{03C8}) | 
#{79} (insert tail result #{03C9}) | 
#{7E} (insert tail result #{00AF}) | 
copy c 1 skip (insert tail result join #{00} c)
]