; ISO_5427-EXT UCS-2 encoding rule
; source:  ftp://dkuug.dk/i18n/charmaps/ISO_5427-EXT
any [
#{40} (insert tail result #{0491}) | 
#{41} (insert tail result #{0452}) | 
#{42} (insert tail result #{0453}) | 
#{43} (insert tail result #{0454}) | 
#{44} (insert tail result #{0451}) | 
#{46} (insert tail result #{0456}) | 
#{47} (insert tail result #{0457}) | 
#{48} (insert tail result #{0458}) | 
#{49} (insert tail result #{0459}) | 
#{4A} (insert tail result #{045A}) | 
#{4B} (insert tail result #{045B}) | 
#{4C} (insert tail result #{045C}) | 
#{4D} (insert tail result #{045E}) | 
#{4E} (insert tail result #{045F}) | 
#{50} (insert tail result #{0463}) | 
#{51} (insert tail result #{0473}) | 
#{52} (insert tail result #{0475}) | 
#{53} (insert tail result #{046B}) | 
#{60} (insert tail result #{0490}) | 
#{61} (insert tail result #{0402}) | 
#{62} (insert tail result #{0403}) | 
#{63} (insert tail result #{0404}) | 
#{64} (insert tail result #{0401}) | 
#{65} (insert tail result #{0405}) | 
#{66} (insert tail result #{0406}) | 
#{67} (insert tail result #{0407}) | 
#{68} (insert tail result #{0408}) | 
#{69} (insert tail result #{0409}) | 
#{6A} (insert tail result #{040A}) | 
#{6B} (insert tail result #{040B}) | 
#{6C} (insert tail result #{040C}) | 
#{6D} (insert tail result #{040E}) | 
#{6E} (insert tail result #{040F}) | 
#{6F} (insert tail result #{042A}) | 
#{70} (insert tail result #{0462}) | 
#{71} (insert tail result #{0472}) | 
#{72} (insert tail result #{0474}) | 
#{73} (insert tail result #{046A}) | 
copy c 1 skip (insert tail result join #{00} c)
]