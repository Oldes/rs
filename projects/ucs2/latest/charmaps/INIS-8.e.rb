; INIS-8 UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/INIS-8
any [
#{3A} (insert tail result #{03B1}) | 
#{3C} (insert tail result #{03B3}) | 
#{3D} (insert tail result #{03B4}) | 
#{3E} (insert tail result #{039E}) | 
#{5E} (insert tail result #{2192}) | 
#{5F} (insert tail result #{222B}) | 
#{60} (insert tail result #{2070}) | 
#{61} (insert tail result #{00B9}) | 
#{62} (insert tail result #{00B2}) | 
#{63} (insert tail result #{00B3}) | 
#{64} (insert tail result #{2074}) | 
#{65} (insert tail result #{2075}) | 
#{66} (insert tail result #{2076}) | 
#{67} (insert tail result #{2077}) | 
#{68} (insert tail result #{2078}) | 
#{69} (insert tail result #{2079}) | 
#{6A} (insert tail result #{207A}) | 
#{6B} (insert tail result #{207B}) | 
#{6C} (insert tail result #{30EB}) | 
#{6D} (insert tail result #{0394}) | 
#{6E} (insert tail result #{039B}) | 
#{6F} (insert tail result #{03A9}) | 
#{70} (insert tail result #{2080}) | 
#{71} (insert tail result #{2081}) | 
#{72} (insert tail result #{2082}) | 
#{73} (insert tail result #{2083}) | 
#{74} (insert tail result #{2084}) | 
#{75} (insert tail result #{2085}) | 
#{76} (insert tail result #{2086}) | 
#{77} (insert tail result #{2087}) | 
#{78} (insert tail result #{2088}) | 
#{79} (insert tail result #{2089}) | 
#{7A} (insert tail result #{03A3}) | 
#{7B} (insert tail result #{03BC}) | 
#{7C} (insert tail result #{03BD}) | 
#{7D} (insert tail result #{03C9}) | 
#{7E} (insert tail result #{03C0}) | 
copy c 1 skip (insert tail result join #{00} c)
]