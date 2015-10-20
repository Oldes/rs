; LATIN-GREEK UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/LATIN-GREEK
any [
#{23} (insert tail result #{00A3}) | 
#{61} (insert tail result #{0391}) | 
#{62} (insert tail result #{0392}) | 
#{63} (insert tail result #{03A8}) | 
#{64} (insert tail result #{0394}) | 
#{65} (insert tail result #{0395}) | 
#{66} (insert tail result #{03A6}) | 
#{67} (insert tail result #{0393}) | 
#{68} (insert tail result #{0397}) | 
#{69} (insert tail result #{0399}) | 
#{6A} (insert tail result #{039E}) | 
#{6B} (insert tail result #{039A}) | 
#{6C} (insert tail result #{039B}) | 
#{6D} (insert tail result #{039C}) | 
#{6E} (insert tail result #{039D}) | 
#{6F} (insert tail result #{039F}) | 
#{70} (insert tail result #{03A0}) | 
#{72} (insert tail result #{03A1}) | 
#{73} (insert tail result #{03A3}) | 
#{74} (insert tail result #{03A4}) | 
#{75} (insert tail result #{0398}) | 
#{76} (insert tail result #{03A9}) | 
#{77} (insert tail result #{00B7}) | 
#{78} (insert tail result #{03A7}) | 
#{79} (insert tail result #{03A5}) | 
#{7A} (insert tail result #{0396}) | 
#{7E} (insert tail result #{00A8}) | 
copy c 1 skip (insert tail result join #{00} c)
]